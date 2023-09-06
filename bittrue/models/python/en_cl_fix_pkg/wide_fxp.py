###################################################################################################
# Copyright (c) 2023 Enclustra GmbH, Switzerland (info@enclustra.com)
###################################################################################################

###################################################################################################
# Description:
#
# The wide_fxp class adds arbitrary-precision support to en_cl_fix_pkg.
#
# Internal data is stored in arbitrary-precision Python integers and all calculations are performed
# on (wide) integers. This differs from "narrow" en_cl_fix_pkg calculations, which are performed
# on (double-precision) floats.
#
# Therefore, wide_fxp internal data is not explicitly normalized according to the fractional bits.
# For example, the fixed-point number 1.25 in FixFormat(0,2,4) has binary representation "01.0100".
# In wide_fxp this is stored internally as integer value 1.25*2**4 = 20. In "narrow" en_cl_fix_pkg,
# it is stored as float value 1.25.
#
# wide_fxp executes significantly more slowly than the "narrow" float implementation, but provides
# support for data widths exceeding 53 bits.
###################################################################################################

import warnings
import copy
import numpy as np

from .en_cl_fix_types import *

_HANDLED_NUMPY_FUNCTIONS = {}


class wide_fxp:
    
    ###############################################################################################
    # Public Functions 
    ###############################################################################################
    
    # Default string representations: Convert to float for consistency with "narrow" en_cl_fix_pkg.
    # Note: To print raw internal integer data, use print(x.data).
    def __repr__(self):
        return (
            "wide_fxp : " + repr(self.fmt) + "\n"
            + "Note: Possible loss of precision in float printout.\n"
            + repr(self.to_narrow_fxp())
        )
    
    def __str__(self):
        return (
            f"wide_fxp {self.fmt}\n"
            f"Note: Possible loss of precision in float printout.\n"
            f"{self.to_narrow_fxp()}"
        )
    
    # Convert from float data to wide_fxp object, with quantization and bounds checks.
    @staticmethod
    def FromFloat(a, rFmt : FixFormat, saturate : FixSaturate = FixSaturate.SatWarn_s):
        # Saturation is mandatory in this function (because wrapping has not been implemented)
        if saturate != FixSaturate.SatWarn_s and saturate != FixSaturate.Sat_s:
            raise ValueError(f"wide_fxp.FromFloat: Unsupported saturation mode {str(saturate)}")
        
        if np.ndim(a) == 0:
            a = np.array(a, ndmin=1)
        
        # Saturation warning
        if (saturate == FixSaturate.SatWarn_s) or (saturate == FixSaturate.Warn_s):
            amax_float = a.max()
            amin_float = a.min()
            amax = wide_fxp.FromNarrowFxp(np.array([amax_float]), rFmt)
            amin = wide_fxp.FromNarrowFxp(np.array([amin_float]), rFmt)
            if amax > wide_fxp.MaxValue(rFmt):
                warnings.warn(f"FromFloat: Number {amax_float} exceeds maximum for format {rFmt}", Warning)
            if amin < wide_fxp.MinValue(rFmt):
                warnings.warn(f"FromFloat: Number {amin_float} exceeds minimum for format {rFmt}", Warning)
        
        # Quantize. Always use half-up rounding.
        x = (a*(2.0**rFmt.F)+0.5).astype('object')
        x = np.floor(x)
        x = wide_fxp(x, rFmt)
        
        # Saturate
        if (saturate == FixSaturate.Sat_s) or (saturate == FixSaturate.SatWarn_s):
            x = np.where(x > wide_fxp.MaxValue(rFmt), wide_fxp.MaxValue(rFmt), x)
            x = np.where(x < wide_fxp.MinValue(rFmt), wide_fxp.MinValue(rFmt), x)
        else:
            # Wrapping is not supported
            None
        
        return x
    
    
    # Convert from narrow (double-precision float) data to wide_fxp object, without bounds checks.
    @staticmethod
    def FromNarrowFxp(data : np.ndarray, fmt : FixFormat):
        data = np.array(data, ndmin=1)
        assert data.dtype == float, "FromNarrowFxp : requires input dtype == float."
        int_data = (data*2.0**fmt.F).astype(object)
        int_data = np.floor(int_data)
        return wide_fxp(int_data, fmt)
    
    
    # Same as FromNarrowFxp, but also allow input to already be wide_fxp. No bounds checks.
    @staticmethod
    def FromFxp(x, fmt : FixFormat):
        if type(x) == wide_fxp:
            assert x.fmt == fmt, "FromFxp : Input was already wide_fxp and its fmt mismatched." \
            f" Got: {x.fmt}. Requested: {fmt}."
            return x
        else:
            return wide_fxp.FromNarrowFxp(x, fmt)
    
    
    # Convert from uint64 array (e.g. from MATLAB).
    @staticmethod
    def FromUint64Array(data : np.ndarray, fmt : FixFormat):
        assert data.dtype == 'uint64', "FromUint64Array : requires input dtype == uint64."
        # Weighted sum to recombine uint64s into wide *unsigned* integers
        weights = 2**(64*np.arange(data.shape[0]).astype(object))
        val = np.matmul(weights, data)
        # Handle the sign bit
        val = np.where(val >= 2**(fmt.I+fmt.F), val - 2**(fmt.I+fmt.F+1), val)
        return wide_fxp(val, fmt)
    
    
    # Calculate maximum representable internal data value (wide_fxp._data) for a given FixFormat.
    @staticmethod
    def MaxValue(fmt : FixFormat):
        val = 2**(fmt.I+fmt.F)-1
        return wide_fxp._FromIntScalar(val, fmt)
    
    
    # Calculate minimum representable internal data value (wide_fxp._data) for a given FixFormat.
    @staticmethod
    def MinValue(fmt : FixFormat):
        if fmt.S == 1:
            val = -2**(fmt.I+fmt.F)
        else:
            val = 0
        return wide_fxp._FromIntScalar(val, fmt)
    
    
    # Align binary points of 2 or more wide_fxp objects (e.g. to perform numerical comparisons).
    # Note: Call as AlignBinaryPoints([a.copy(), b.copy()]) to prevent originals being modified.
    @staticmethod
    def AlignBinaryPoints(WfxpList):
        # Find the maximum number of frac bits
        Fmax = max(Array.fmt.F for Array in WfxpList)

        # Resize every input to align binary points
        for i, Wfxp in enumerate(WfxpList):
            rFmt = FixFormat(Wfxp.fmt.S, Wfxp.fmt.I, Fmax)
            WfxpList[i] = Wfxp.resize(rFmt)

        return WfxpList
    
    
    # Get internal integer data
    @property
    def data(self):
        return self._data
    
    
    # Get fixed-point format
    @property
    def fmt(self):
        return self._fmt
    
    
    @property
    def size(self):
        return self._data.size
    
    
    @property
    def shape(self):
        return self._data.shape
    
    
    @property
    def T(self):
        return wide_fxp(self._data.T, self._fmt)
    
    
    # Get data in human-readable floating-point format (with loss of precision), with bounds checks
    def to_float(self):
        # To avoid this warning, call to_narrow_fxp() directly.
        if (self.fmt.S == 1 and (np.any(self.data < -2**52) or np.any(self.data >= 2**52))) \
            or (self.fmt.S == 0 and np.any(self.data >= 2**53)):
            warnings.warn("to_float : Possible loss of precision when converting wide_fxp data to float!", Warning)
        return self.to_narrow_fxp()
    
    
    # Get narrow (double-precision float) representation of data. No bounds checks.
    def to_narrow_fxp(self):
        # Note: This function performs no range/precision checks.
        return np.array(self._data/2.0**self._fmt.F).astype(float)


    # Pack data into uint64 array (e.g. for passing to MATLAB).
    # Data is packed into columns, so result[:,k] corresponds to data[k].
    def to_uint64_array(self):
        val = self._data
        fmt = self._fmt
        
        # Calculate number of uint64s needed per element
        fmtWidth = fmt.width
        nInts = (fmtWidth + 63) // 64  # ceil(width / 64)

        # Cast to unsigned by reintepreting the sign bit
        val = np.where(val < 0, val + 2**fmtWidth, val)

        # Populate 2D uint64 array
        uint64Array = np.empty((nInts,) + val.shape, dtype='uint64')
        for i in range(nInts):
            uint64Array[i,:] = val % 2**64
            val >>= 64
        
        return uint64Array


    # Shallow copy
    def copy(self):
        return wide_fxp(self._data.copy(), copy.copy(self._fmt))


    # Maximum value in object's data array
    def max(self):
        return wide_fxp._FromIntScalar(self._data.max(), self._fmt)


    # Minimum value in object's data array
    def min(self):
        return wide_fxp._FromIntScalar(self._data.min(), self._fmt)


    # Create a new wide_fxp object with a new fixed-point format after rounding.
    def round(self, rFmt : FixFormat, rnd : FixRound = FixRound.Trunc_s):
        assert rFmt == FixFormat.ForRound(self._fmt, rFmt.F, rnd), "round: Invalid result format. Use FixFormat.ForRound()."
        
        # Copy object data so self is not modified and take floor to enforce int object type
        val = np.floor(self._data)
        
        # Shorthands
        fmt = self._fmt
        f = fmt.F
        fr = rFmt.F
        
        # Add offset before truncating to implement rounding
        if fr < f:
            # Frac bits decrease => do rounding
            if rnd is FixRound.Trunc_s:
                # Truncate => Always round towards -Inf.
                pass
            elif rnd is FixRound.NonSymPos_s:
                # Half-up => Round to "nearest", all ties rounded towards +Inf.
                val = val + 2**(f - fr - 1)       # + "half"
            elif rnd is FixRound.NonSymNeg_s:
                # Half-down => Round to "nearest", all ties rounded towards -Inf.
                val = val + (2**(f - fr - 1) - 1) # + "half"-delta
            elif rnd is FixRound.SymInf_s:
                # Half-away-from-zero => Round to "nearest", all ties rounded away from zero.
                #                     => Half-up for val>0. Half-down for val<0.
                offset = np.array(val < 0, dtype=int).astype(object)
                val = val + (2**(f - fr - 1) - offset)
            elif rnd is FixRound.SymZero_s:
                # Half-towards-zero => Round to "nearest", all ties rounded towards zero.
                #                   => Half-up for val<0. Half-down for val>0.
                offset = np.array(val >= 0, dtype=int).astype(object)
                val = val + (2**(f - fr - 1) - offset)
            elif rnd is FixRound.ConvEven_s:
                # Convergent-even => Round to "nearest", all ties rounded to nearest "even" number (b"X..XX0").
                #                 => Half-down for trunc(val) even, else half-up.
                trunc_a = val >> (f - fr)
                trunc_a_iseven = (trunc_a + 1) % 2
                val = val + (2**(f - fr - 1) - trunc_a_iseven*1)
            elif rnd is FixRound.ConvOdd_s:
                # Convergent-odd => Round to "nearest", all ties rounded to nearest "odd" number (b"X..XX1").
                #                => Half-down for trunc(val) odd, else half-up.
                trunc_a = val >> (f - fr)
                trunc_a_isodd = trunc_a % 2
                val = val + (2**(f - fr - 1) - trunc_a_isodd*1)
            else:
                raise Exception("resize : Illegal value for round!")
            
            # Truncate
            shift = f - fr
            val >>= shift
        elif fr > f:
            # Frac bits increase => safely scale up
            val = val * 2**(fr - f)
        else:
            # Frac bits don't change => No rounding or scaling
            pass
            
        return wide_fxp(val, rFmt)

    # Create a new wide_fxp object with a new fixed-point format after saturation.
    def saturate(self, rFmt : FixFormat, sat : FixSaturate = FixSaturate.None_s):
        # Copy object data so self is not modified and take floor to enforce int object type
        val = np.floor(self._data)
        
        # Saturation warning
        if sat == FixSaturate.Warn_s or sat == FixSaturate.SatWarn_s:
            if np.any(val > wide_fxp.MaxValue(rFmt).data) or np.any(val < wide_fxp.MinValue(rFmt).data):
                warnings.warn("resize : Saturation warning!", Warning)
        
        # Saturation
        if sat == FixSaturate.None_s or sat == FixSaturate.Warn_s:
            # Wrap
            satSpan = 2**(rFmt.I + rFmt.F)
            if rFmt.S == 1:
                val = ((val + satSpan) % (2*satSpan)) - satSpan
            else:
                val = val % satSpan
        else:
            # Saturate
            val = np.where(val > wide_fxp.MaxValue(rFmt).data, wide_fxp.MaxValue(rFmt).data, val)
            val = np.where(val < wide_fxp.MinValue(rFmt).data, wide_fxp.MinValue(rFmt).data, val)
            
        return wide_fxp(val, rFmt)

    # Create a new wide_fxp object with a new fixed-point format after rounding and saturation.
    def resize(self, rFmt : FixFormat,
               rnd : FixRound = FixRound.Trunc_s,
               sat : FixSaturate = FixSaturate.None_s):
        
        # Round
        roundedFmt = FixFormat.ForRound(self._fmt, rFmt.F, rnd)
        rounded = self.round(roundedFmt, rnd)
        
        # Saturate
        result = rounded.saturate(rFmt, sat)
        
        return result
    
    # Create a new wide_fxp object with the most significant bit (- index) set to "value"
    def set_msb(self, index, value):
        if np.any(value > 1) or np.any(value < 0):
            raise Exception("wide_fxp.set_msb: only 1 and 0 allowed for value")
        fmt = self.fmt
        if fmt.S == 1 and index == 0:
            weight = -2**(fmt.width-1-index)
        else:
            weight = 2**(fmt.width-1-index)
        val = np.where(self.get_msb(index) != value, self.data - weight*(-1)**value, self.data)
        return wide_fxp(val, fmt)
    
    
    # Get most significant bit (- index)
    def get_msb(self, index):
        fmt = self._fmt
        if fmt.S == 1 and index == 0:
            return (self._data < 0).astype(int)
        else:
            shift = fmt.width-1 - index
            return ((self._data >> shift) % 2).astype(int)
    
    
    # Discard fractional bits (keeping integer bits). Rounds towards -Inf.
    def floor(self):
        fmt = self._fmt
        rFmt = FixFormat(fmt.S, fmt.I, 0)
        if fmt.F >= 0:
            return wide_fxp(self._data >> fmt.F, rFmt)
        else:
            return wide_fxp(self._data << -fmt.F, rFmt)
    
    
    # Get the integer part
    def int_part(self):
        return self.floor()
    
    
    # Get the fractional part.
    # Note: Result has implicit frac bits if I<0.
    def frac_part(self):
        fmt = self._fmt
        rFmt = FixFormat(False, min(fmt.I, 0), fmt.F)
        # Drop the sign bit
        val = self._data
        if fmt.S == 1:
            offset = 2**(fmt.F+fmt.I)
            val = np.where(val < 0, val + offset, val)
        # Retain fractional LSBs
        val = val % 2**rFmt.width
        return wide_fxp(val, rFmt)


    def reshape(self, shape, order='C'):
        return wide_fxp(self._data.reshape(shape, order=order), self._fmt)
    
    
    def flatten(self, order='C'):
        return wide_fxp(self._data.flatten(order=order), self._fmt)

    ###############################################################################################
    # Private Functions 
    ###############################################################################################

    # Construct wide_fxp object from internal integer data representation and FixFormat.
    # Note: Call as wide_fxp(x.copy(), copy.copy(fmt)) to prevent originals from being modified.
    # Note: Considered private to avoid a user thinking they can pass normalized fixed-point
    # numbers (which happen to be round integers) instead of unnormalized internal data. For
    # example, the fixed-point value 3.0 in FixFormat(0,2,4) has internal data value 3.0*2**4 = 48
    # and *not* 3.
    # Note: en_cl_fix_pkg is considered like a friend class, so may call this constructor directly.
    # Note: Users can use public static methods such as FromFloat() to construct wide_fxp objects,
    #       but it is recommended to just use the en_cl_fix_pkg functions instead (since they
    #       choose the best internal representation automatically).
    def __init__(self, data : np.ndarray, fmt : FixFormat):
        assert data.dtype == object, "wide_fxp : requires arbitrary-precision int (dtype == object)."
        assert type(fmt) == FixFormat, "wide_fxp : fmt must be of type en_cl_fix_types.FixFormat."
        self._data = data
        self._fmt = fmt
        
    
    # Same as __init__, except the internal integer data is a scalar (arbitrary-precision int).
    @staticmethod
    def _FromIntScalar(data : int, fmt : FixFormat):
        return wide_fxp(np.array([data]).astype(object), fmt)
    
    
    # Reference: https://numpy.org/doc/stable/user/basics.dispatch.html
    def __array_function__(self, func, types, args, kwargs):
        if func not in _HANDLED_NUMPY_FUNCTIONS:
            return NotImplemented
        # Note: this allows subclasses that don't override __array_function__ to handle wide_fxp
        # objects.
        # WARNING! The "any" below should be "all"? But then the method fails to register. TODO.
        if not any(issubclass(t, self.__class__) for t in types):
            return NotImplemented
        return _HANDLED_NUMPY_FUNCTIONS[func](*args, **kwargs)
    
    
    # Support [] access (get)
    def __getitem__(self, key):
        data = self._data[key]
        if isinstance(data, int):
            return wide_fxp._FromIntScalar(data, self._fmt)
        else:
            return wide_fxp(data, self._fmt)
    
    
    # Support [] access (set)
    def __setitem__(self, key, value):
        assert value.fmt == self._fmt, "Format mismatch in wide_fxp[key] = value assignment."
        if isinstance(self._data[key], int):
            self._data[key] = value.data[0]
        else:
            self._data[key] = value.data
    
    
    # "+" operator
    def __add__(self, other):
        aFmt = self._fmt
        bFmt = other._fmt
        rFmt = FixFormat.ForAdd(aFmt, bFmt)
        
        a = self.copy()
        b = other.copy()
        
        # Align binary points without truncating any MSBs or LSBs
        aRoundFmt = FixFormat.ForRound(a.fmt, rFmt.F, FixRound.Trunc_s)
        bRoundFmt = FixFormat.ForRound(b.fmt, rFmt.F, FixRound.Trunc_s)
        a = a.round(aRoundFmt)
        b = b.round(bRoundFmt)
        
        # Do addition on internal integer data (binary points are aligned)
        return wide_fxp(a.data + b.data, rFmt)
    
    
    # "-" operator
    def __sub__(self, other):
        aFmt = self._fmt
        bFmt = other._fmt
        rFmt = FixFormat.ForSub(aFmt, bFmt)
        
        a = self.copy()
        b = other.copy()
        
        # Align binary points without truncating any MSBs or LSBs
        aRoundFmt = FixFormat.ForRound(a.fmt, rFmt.F, FixRound.Trunc_s)
        bRoundFmt = FixFormat.ForRound(b.fmt, rFmt.F, FixRound.Trunc_s)
        a = a.round(aRoundFmt)
        b = b.round(bRoundFmt)
        
        # Do subtraction on internal integer data (binary points are aligned)
        return wide_fxp(a.data - b.data, rFmt)
    
    # Unary "-" operator
    def __neg__(self):
        rFmt = FixFormat.ForNeg(self._fmt)
        return wide_fxp(-self._data, rFmt)
    
    
    # "*" operator
    def __mul__(self, other):
        rFmt = FixFormat.ForMult(self._fmt, other.fmt)
        return wide_fxp(self._data * other.data, rFmt)
    
    
    # Helper function to consistently extract data for comparison operators
    def _extract_comparison_data(self, other):
        # Special case: allow comparisons with integer 0
        if type(other) == int:
            assert other == 0, "wide_fxp can only be compared with int 0. " + \
            "All other values can be converted using wide_fxp._FromIntScalar(val, fmt)"
            other = wide_fxp._FromIntScalar(other, self._fmt)
        # For consistency with narrow implementation, convert to a common format
        a, b = wide_fxp.AlignBinaryPoints([self.copy(), other.copy()])
        return a.data, b.data
    
    
    # "==" operator
    def __eq__(self, other):
        a, b = self._extract_comparison_data(other)
        return a == b
    
    
    # "!=" operator
    def __ne__(self, other):
        a, b = self._extract_comparison_data(other)
        return a != b
    
    
    # "<" operator
    def __lt__(self, other):
        a, b = self._extract_comparison_data(other)
        return a < b
    
    
    # "<=" operator
    def __le__(self, other):
        a, b = self._extract_comparison_data(other)
        return a <= b
    
    
    # ">" operator
    def __gt__(self, other):
        a, b = self._extract_comparison_data(other)
        return a > b
    
    
    # ">=" operator
    def __ge__(self, other):
        a, b = self._extract_comparison_data(other)
        return a >= b
    
    
    # len()
    def __len__(self):
        return len(self._data)
    
    
###################################################################################################
# Non-Member Functions
###################################################################################################
    
# Decorator for adding functions to _HANDLED_NUMPY_FUNCTIONS.
# Reference: https://numpy.org/doc/stable/user/basics.dispatch.html
def implements(np_function):
    """Register an __array_function__ implementation for wide_fxp objects."""
    def decorator(func):
        _HANDLED_NUMPY_FUNCTIONS[np_function] = func
        return func
    return decorator
    
    
# Implementation of np.where() for wide_fxp objects.
@implements(np.where)
def where(*args, **kwargs):
    # The condition is an ordinary np.ndarray(bool)
    condition = args[0]
    # Both of the choices are wide_fxp objects
    x = args[1]
    y = args[2]
    assert x.fmt == y.fmt, "wide_fxp np.where() : Cannot mix formats."
    
    result = np.where(condition, x.data, y.data, *args[3:], **kwargs)
    return wide_fxp(result, x.fmt)
    
    
# Implementation of np.array_equal() for wide_fxp objects.
@implements(np.array_equal)
def array_equal(*args, **kwargs):
    # Both of the inputs are wide_fxp objects
    x = args[0]
    y = args[1]
    
    # Preferable to raise error if shapes mismatch (instead of quietly returning False)
    assert x.data.shape == y.data.shape, "wide_fxp array_equal : data shape mismatch"
    
    return np.all(x == y)
    
    
# Implementation of np.concatenate() for wide_fxp objects.
@implements(np.concatenate)
def concatenate(*args, **kwargs):
    # Inputs are passed in a tuple
    tup = args[0]
    for x in tup:
        assert x.fmt == tup[0].fmt, "wide_fxp np.concatenate() : Cannot mix formats."
    
    result = np.concatenate(tuple(x.data for x in tup), *args[1:], **kwargs)
    return wide_fxp(result, tup[0].fmt)
