###################################################################################################
# Copyright (c) 2023 Enclustra GmbH, Switzerland (info@enclustra.com)
###################################################################################################

###################################################################################################
# Description:
#
# The WideFix class adds arbitrary-precision support to en_cl_fix_pkg.
#
# Internal data is stored in arbitrary-precision Python integers and all calculations are performed
# on (wide) integers. This differs from "narrow" en_cl_fix_pkg calculations, which are performed
# on (double-precision) floats.
#
# Therefore, WideFix internal data is not explicitly normalized according to the fractional bits.
# For example, the fixed-point number 1.25 in FixFormat(0,2,4) has binary representation "01.0100".
# In WideFix this is stored internally as integer value 1.25*2**4 = 20. In "narrow" en_cl_fix_pkg,
# it is stored as float value 1.25.
#
# WideFix executes significantly more slowly than the "narrow" float implementation, but provides
# support for data widths exceeding 53 bits.
###################################################################################################

import warnings
import numpy as np
from copy import copy as shallow_copy
from copy import deepcopy as deep_copy

from .en_cl_fix_types import *


class WideFix:
    
    ###############################################################################################
    # Public Functions 
    ###############################################################################################
    
    # Construct WideFix object from internal integer data representation and FixFormat.
    # Example: the fixed-point value 3.0 in FixFormat(0,2,4) has internal data value 3.0*2**4 = 48
    # and *not* 3.
    def __init__(self, data, fmt : FixFormat, copy=True):
        if isinstance(data, int):
            data = np.array(data, dtype=object)
        assert data.dtype == object, "WideFix: requires arbitrary-precision int (dtype == object)."
        assert isinstance(data.flat[0], int), "WideFix: requires arbitrary-precision int (dtype == object)."
        if copy:
            self._data = data.copy()
        else:
            self._data = data
        # Always copy the format (very small)
        self._fmt = shallow_copy(fmt)
    
    # Convert from float data to WideFix object, with quantization and bounds checks.
    @staticmethod
    def FromFloat(a, r_fmt : FixFormat, saturate : FixSaturate = FixSaturate.SatWarn_s):
        # Saturation is mandatory in this function (because wrapping has not been implemented)
        if saturate != FixSaturate.SatWarn_s and saturate != FixSaturate.Sat_s:
            raise ValueError(f"WideFix.FromFloat: Unsupported saturation mode {str(saturate)}")
        if isinstance(a, float):
            a = np.array(a)
        
        # Saturation warning
        if (saturate == FixSaturate.SatWarn_s) or (saturate == FixSaturate.Warn_s):
            amax_float = a.max()
            amin_float = a.min()
            amax = WideFix.FromNarrowFxp(np.array([amax_float]), r_fmt)._data
            amin = WideFix.FromNarrowFxp(np.array([amin_float]), r_fmt)._data
            if amax > WideFix.MaxValue(r_fmt)._data:
                warnings.warn(f"FromFloat: Number {amax_float} exceeds maximum for format {r_fmt}", Warning)
            if amin < WideFix.MinValue(r_fmt)._data:
                warnings.warn(f"FromFloat: Number {amin_float} exceeds minimum for format {r_fmt}", Warning)
        
        # Quantize. Always use half-up rounding.
        x = (a*(2.0**r_fmt.F)+0.5).astype('object')
        x = np.floor(x)
        
        # Saturate
        if (saturate == FixSaturate.Sat_s) or (saturate == FixSaturate.SatWarn_s):
            x = np.where(x > WideFix.MaxValue(r_fmt)._data, WideFix.MaxValue(r_fmt)._data, x)
            x = np.where(x < WideFix.MinValue(r_fmt)._data, WideFix.MinValue(r_fmt)._data, x)
        else:
            # Wrapping is not supported
            None
        
        return WideFix(x, r_fmt)
    
    # Convert from narrow (double-precision float) data to WideFix object, without bounds checks.
    @staticmethod
    def FromNarrowFxp(data : np.ndarray, fmt : FixFormat):
        data = np.array(data, ndmin=1)
        assert data.dtype == float, "FromNarrowFxp : requires input dtype == float."
        int_data = (data*2.0**fmt.F).astype(object)
        int_data = np.floor(int_data)
        return WideFix(int_data, fmt)
    
    # Convert from uint64 array (e.g. from MATLAB).
    @staticmethod
    def FromUint64Array(data : np.ndarray, fmt : FixFormat):
        assert data.dtype == 'uint64', "FromUint64Array : requires input dtype == uint64."
        # Weighted sum to recombine uint64s into wide *unsigned* integers
        weights = 2**(64*np.arange(data.shape[0]).astype(object))
        val = np.matmul(weights, data)
        # Handle the sign bit
        val = np.where(val >= 2**(fmt.I+fmt.F), val - 2**(fmt.I+fmt.F+1), val)
        return WideFix(val, fmt)
    
    # Calculate maximum representable internal data value (WideFix._data) for a given FixFormat.
    @staticmethod
    def MaxValue(fmt : FixFormat):
        val = 2**(fmt.I+fmt.F)-1
        return WideFix(val, fmt, copy=False)
    
    # Calculate minimum representable internal data value (WideFix._data) for a given FixFormat.
    @staticmethod
    def MinValue(fmt : FixFormat):
        if fmt.S == 1:
            val = -2**(fmt.I+fmt.F)
        else:
            val = 0
        return WideFix(val, fmt, copy=False)
    
    # Align binary points of 2 or more WideFix objects (e.g. to perform numerical comparisons).
    @staticmethod
    def AlignBinaryPoints(values):
        values = deep_copy(values)
        
        # Find the maximum number of frac bits
        Fmax = max(value.fmt.F for value in values)

        # Resize every input to align binary points
        for i, value in enumerate(values):
            r_fmt = FixFormat(value.fmt.S, value.fmt.I, Fmax)
            values[i] = value.resize(r_fmt)

        return values
    
    # Get internal integer data
    @property
    def data(self):
        return self._data.copy()
    
    # Get fixed-point format
    @property
    def fmt(self):
        return shallow_copy(self._fmt)
    
    # Get data in human-readable floating-point format (with loss of precision), with bounds checks
    def to_real(self, warn=True):
        if warn:
            if (self.fmt.S == 1 and (np.any(self.data < -2**52) or np.any(self.data >= 2**52))) \
                or (self.fmt.S == 0 and np.any(self.data >= 2**53)):
                warnings.warn("WideFix.to_real: Possible loss of precision when converting WideFix data to float!", Warning)
        return np.array(self._data/2.0**self._fmt.F, dtype=np.float64)

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

    # Create a new WideFix object with a new fixed-point format after rounding.
    def round(self, r_fmt : FixFormat, rnd : FixRound = FixRound.Trunc_s):
        assert r_fmt == FixFormat.ForRound(self._fmt, r_fmt.F, rnd), "round: Invalid result format. Use FixFormat.ForRound()."
        
        # Copy object data so self is not modified and take floor to enforce int object type
        val = np.floor(self._data)
        
        # Shorthands
        fmt = self._fmt
        f = fmt.F
        fr = r_fmt.F
        
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
            
        return WideFix(val, r_fmt)

    # Create a new WideFix object with a new fixed-point format after saturation.
    def saturate(self, r_fmt : FixFormat, sat : FixSaturate = FixSaturate.None_s):
        # Copy object data so self is not modified and take floor to enforce int object type
        val = np.floor(self._data)
        
        # Saturation warning
        if sat == FixSaturate.Warn_s or sat == FixSaturate.SatWarn_s:
            if np.any(val > WideFix.MaxValue(r_fmt).data) or np.any(val < WideFix.MinValue(r_fmt).data):
                warnings.warn("resize : Saturation warning!", Warning)
        
        # Saturation
        if sat == FixSaturate.None_s or sat == FixSaturate.Warn_s:
            # Wrap
            satSpan = 2**(r_fmt.I + r_fmt.F)
            if r_fmt.S == 1:
                val = ((val + satSpan) % (2*satSpan)) - satSpan
            else:
                val = val % satSpan
        else:
            # Saturate
            val = np.where(val > WideFix.MaxValue(r_fmt).data, WideFix.MaxValue(r_fmt).data, val)
            val = np.where(val < WideFix.MinValue(r_fmt).data, WideFix.MinValue(r_fmt).data, val)
            
        return WideFix(val, r_fmt)

    # Create a new WideFix object with a new fixed-point format after rounding and saturation.
    def resize(self, r_fmt : FixFormat,
               rnd : FixRound = FixRound.Trunc_s,
               sat : FixSaturate = FixSaturate.None_s):
        
        # Round
        roundedFmt = FixFormat.ForRound(self._fmt, r_fmt.F, rnd)
        rounded = self.round(roundedFmt, rnd)
        
        # Saturate
        result = rounded.saturate(r_fmt, sat)
        
        return result
    
    def abs(self, r_fmt : FixFormat = None, rnd : FixRound = FixRound.Trunc_s, sat : FixSaturate = FixSaturate.None_s):
        """
        Calculates absolute values, abs(self).
        """
        mid_fmt = FixFormat.ForAbs(self._fmt)
        if r_fmt is None:
            r_fmt = mid_fmt
        neg = self.neg(mid_fmt)
        pos = self.resize(mid_fmt)
        
        data_abs = np.where(self._data < 0, neg._data, pos._data)
        return WideFix(data_abs, mid_fmt, copy=False).resize(r_fmt, rnd, sat)

    def neg(self, r_fmt : FixFormat = None, rnd : FixRound = FixRound.Trunc_s, sat : FixSaturate = FixSaturate.None_s):
        """
        Calculates negation, -self.
        """
        mid_fmt = FixFormat.ForNeg(self._fmt)
        if r_fmt is None:
            r_fmt = mid_fmt
        return WideFix(-self._data, mid_fmt, copy=False).resize(r_fmt, rnd, sat)
        
    def add(self, b : "WideFix",
            r_fmt : FixFormat = None,
            rnd : FixRound = FixRound.Trunc_s, sat : FixSaturate = FixSaturate.None_s):
        """
        Calculates addition, self + b.
        """
        a = self
        mid_fmt = FixFormat.ForAdd(a._fmt, b._fmt)
        if r_fmt is None:
            r_fmt = mid_fmt
        
        # Align binary points without truncating any MSBs or LSBs
        a_round_fmt = FixFormat.ForRound(a._fmt, mid_fmt.F, FixRound.Trunc_s)
        b_round_fmt = FixFormat.ForRound(b._fmt, mid_fmt.F, FixRound.Trunc_s)
        a_round = a.round(a_round_fmt)
        b_round = b.round(b_round_fmt)
        
        # Do addition on internal integer data (binary points are aligned)
        return WideFix(a_round._data + b_round._data, mid_fmt).resize(r_fmt, rnd, sat)

    def sub(self, b : "WideFix",
            r_fmt : FixFormat = None,
            rnd : FixRound = FixRound.Trunc_s, sat : FixSaturate = FixSaturate.None_s):
        """
        Calculates subtraction, self - b.
        """
        a = self
        mid_fmt = FixFormat.ForSub(a._fmt, b._fmt)
        if r_fmt is None:
            r_fmt = mid_fmt
        
        # Align binary points without truncating any MSBs or LSBs
        a_round_fmt = FixFormat.ForRound(a._fmt, mid_fmt.F, FixRound.Trunc_s)
        b_round_fmt = FixFormat.ForRound(b._fmt, mid_fmt.F, FixRound.Trunc_s)
        a_round = a.round(a_round_fmt)
        b_round = b.round(b_round_fmt)
        
        # Do addition on internal integer data (binary points are aligned)
        return WideFix(a_round._data - b_round._data, mid_fmt).resize(r_fmt, rnd, sat)
        
    def addsub(self, b : "WideFix", add,  # Bool or bool array.
               r_fmt : FixFormat = None,
               rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
        """
        Calculates addition/subtraction:
            self + b, where add == True.
            self - b, where add == False.
        """
        # mid_fmt = FixFormat.ForAddsub(self._fmt, b._fmt)
        # if r_fmt is None:
            # r_fmt = mid_fmt
        # radd = self.add(b, r_fmt, rnd, sat)
        # rsub = self.sub(b, r_fmt, rnd, sat)
        # r_data = np.where(add, radd._data, rsub._data)
        # return NarrowFix(r_data, r_fmt, copy=False)

    def mult(self, b : "WideFix",
             r_fmt : FixFormat = None,
             rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
        """
        Calculates multiplication, self * b.
        """
        mid_fmt = FixFormat.ForMult(self._fmt, b._fmt)
        if r_fmt is None:
            r_fmt = mid_fmt
        return WideFix(self._data * b._data, mid_fmt, copy=False).resize(r_fmt, rnd, sat)

    def shift(self, shift,
              r_fmt : FixFormat = None,
              rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
        """
        Calculates a left bit-shift (equivalent to *2.0**shift). To shift right, set shift < 0.
        
        Note: This function performs a lossless shift (equivalent to *2.0**shift), then resizes to the
        output format. The initial shift does NOT truncate any bits.
        """
        mid_fmt = FixFormat.ForShift(self._fmt, np.min(shift), np.max(shift))
        if r_fmt is None:
            r_fmt = mid_fmt
        
        if np.ndim(shift) == 0:
            # Change format without changing data values => shift
            mid = WideFix(self._data, mid_fmt)
        else:
            # Variable shift (each value individually)
            assert shift.size == self._data.size, "WideFix.__lshift__: shift must be 0d or the same length as data"
            mid = WideFix(np.zeros(self._data.size, dtype=object), mid_fmt)
            for i, s in enumerate(shift):
                # Change format without changing data values => shift
                temp_fmt = FixFormat.ForShift(self._fmt, s)
                temp = WideFix(self._data[i], temp_fmt, copy=False)
                # Resize to the shared intermediate format
                mid._data[i] = temp.resize(mid_fmt)._data[0]
        
        return WideFix(mid, mid_fmt, copy=False).resize(r_fmt, rnd, sat)
    
    # Create a new WideFix object with the most significant bit (- index) set to "value"
    def set_msb(self, index, value):
        if np.any(value > 1) or np.any(value < 0):
            raise Exception("WideFix.set_msb: only 1 and 0 allowed for value")
        fmt = self.fmt
        if fmt.S == 1 and index == 0:
            weight = -2**(fmt.width-1-index)
        else:
            weight = 2**(fmt.width-1-index)
        val = np.where(self.get_msb(index) != value, self.data - weight*(-1)**value, self.data)
        return WideFix(val, fmt)
    
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
        r_fmt = FixFormat(fmt.S, fmt.I, 0)
        if fmt.F >= 0:
            return WideFix(self._data >> fmt.F, r_fmt)
        else:
            return WideFix(self._data << -fmt.F, r_fmt)
    
    # Get the integer part
    def int_part(self):
        return self.floor()
    
    # Get the fractional part.
    # Note: Result has implicit frac bits if I<0.
    def frac_part(self):
        fmt = self._fmt
        r_fmt = FixFormat(False, min(fmt.I, 0), fmt.F)
        # Drop the sign bit
        val = self._data
        if fmt.S == 1:
            offset = 2**(fmt.F+fmt.I)
            val = np.where(val < 0, val + offset, val)
        # Retain fractional LSBs
        val = val % 2**r_fmt.width
        return WideFix(val, r_fmt)
    
    # Default string representations: Convert to float for consistency with "narrow" en_cl_fix_pkg.
    # Note: To print raw internal integer data, use print(x.data).
    def __repr__(self):
        return (
            "WideFix : " + repr(self.fmt) + "\n"
            + "Note: Possible loss of precision in float printout.\n"
            + repr(self.to_real(warn=False))
        )
    
    def __str__(self):
        return (
            f"WideFix {self.fmt}\n"
            f"Note: Possible loss of precision in float printout.\n"
            f"{self.to_real(warn=False)}"
        )
    
    # "+" operator
    def __add__(self, other):
        return self.add(other)
    
    # "-" operator
    def __sub__(self, other):
        return self.sub(other)
    
    # Unary "-" operator
    def __neg__(self):
        return self.neg()
    
    # "*" operator
    def __mul__(self, other):
        return self.mult(other)
    
    # "<<" operator
    def __lshift__(self, shift):
        return self.shift(shift)
    
    # "==" operator
    def __eq__(self, other):
        a, b = WideFix.AlignBinaryPoints([self, other])
        return a._data == b._data
    
    # "!=" operator
    def __ne__(self, other):
        a, b = WideFix.AlignBinaryPoints([self, other])
        return a._data != b._data
    
    # "<" operator
    def __lt__(self, other):
        a, b = WideFix.AlignBinaryPoints([self, other])
        return a._data < b._data
    
    # "<=" operator
    def __le__(self, other):
        a, b = WideFix.AlignBinaryPoints([self, other])
        return a._data <= b._data
    
    # ">" operator
    def __gt__(self, other):
        a, b = WideFix.AlignBinaryPoints([self, other])
        return a._data > b._data
    
    # ">=" operator
    def __ge__(self, other):
        a, b = WideFix.AlignBinaryPoints([self, other])
        return a._data >= b._data
    
    # len()
    def __len__(self):
        return len(self._data)
