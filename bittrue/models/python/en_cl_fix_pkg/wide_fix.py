###################################################################################################
# Copyright (c) 2023 Enclustra GmbH, Switzerland (info@enclustra.com)
###################################################################################################

###################################################################################################
# Description:
#
# The WideFix class adds arbitrary-precision support to en_cl_fix_pkg.
#
# Internal data is stored in arbitrary-precision Python integers and all calculations are performed
# on (wide) integers. This differs from NarrowFix, which uses (double-precision) floats.
#
# Therefore, WideFix internal data is not explicitly normalized according to the fractional bits.
# For example, the fixed-point number 1.25 in FixFormat(0,2,4) has binary representation "01.0100".
# In WideFix this is stored internally as integer value 1.25*2**4 = 20. In NarrowFix, it would be
# stored as float value 1.25.
#
# WideFix executes significantly more slowly than the NarrowFix, but provides support for data
# widths exceeding 53 bits.
###################################################################################################

import warnings
import numpy as np
from copy import copy as shallow_copy
from copy import deepcopy as deep_copy

from .en_cl_fix_types import *


class WideFix:
    
    def __init__(self, data, fmt : FixFormat, copy=True):
        """
        Constructs a WideFix object from the internal integer data representation.
        Example: the fixed-point value 3.0 in FixFormat(0,2,4) has internal data value 3.0*2**4 =
        48 (and *not* 3).
        """
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
    
    @staticmethod
    def from_real(a, r_fmt : FixFormat, saturate : FixSaturate = FixSaturate.SatWarn_s):
        """
        Converts from floating-point to WideFix, with half-up rounding and saturation.
        
        Note: If a different rounding mode is needed, or if saturation is not desired, then use
        resize().
        """
        # Saturation warning
        if (saturate == FixSaturate.SatWarn_s) or (saturate == FixSaturate.Warn_s):
            amax_float = np.max(a)
            amin_float = np.min(a)
            amax = int(amax_float*2.0**r_fmt.F)
            amin = int(amin_float*2.0**r_fmt.F)
            if amax > WideFix.max_value(r_fmt)._data:
                warnings.warn(f"from_real: Number {amax_float} exceeds maximum for format {r_fmt}", Warning)
            if amin < WideFix.min_value(r_fmt)._data:
                warnings.warn(f"from_real: Number {amin_float} exceeds minimum for format {r_fmt}", Warning)
        
        # Quantize. Always use half-up rounding.
        x = (a*(2.0**r_fmt.F)+0.5).astype('object')
        x = np.floor(x)
        
        # Saturate
        if (saturate == FixSaturate.Sat_s) or (saturate == FixSaturate.SatWarn_s):
            x = np.where(x > WideFix.max_value(r_fmt)._data, WideFix.max_value(r_fmt)._data, x)
            x = np.where(x < WideFix.min_value(r_fmt)._data, WideFix.min_value(r_fmt)._data, x)
        else:
            # Wrapping has not been implemented
            raise NotImplementedError(f"WideFix: Unsupported saturation mode {str(saturate)}")
        
        return WideFix(x, r_fmt)
    
    @staticmethod
    def from_narrowfix(a : "NarrowFix"):
        """
        Converts from NarrowFix to WideFix, without quantization or bounds checks.
        """
        int_data = np.floor((a._data*2.0**a._fmt.F).astype(object))
        return WideFix(int_data, a._fmt, copy=False)
    
    @staticmethod
    def from_uint64_array(data : np.ndarray, fmt : FixFormat):
        """
        Converts from uint64 array (e.g. from MATLAB) to WideFix.
        """
        assert data.dtype == 'uint64', "from_uint64_array : requires input dtype == uint64."
        # Weighted sum to recombine uint64s into wide *unsigned* integers
        weights = 2**(64*np.arange(data.shape[0]).astype(object))
        val = np.matmul(weights, data)
        # Handle the sign bit
        val = np.where(val >= 2**(fmt.I+fmt.F), val - 2**(fmt.I+fmt.F+1), val)
        return WideFix(val, fmt)
    
    @staticmethod
    def max_value(fmt : FixFormat):
        """
        Calculates the maximum representable value for a given FixFormat.
        """
        val = 2**(fmt.I+fmt.F)-1
        return WideFix(val, fmt, copy=False)
    
    @staticmethod
    def min_value(fmt : FixFormat):
        """
        Calculates the minimum representable value for a given FixFormat.
        """
        if fmt.S == 1:
            val = -2**(fmt.I+fmt.F)
        else:
            val = 0
        return WideFix(val, fmt, copy=False)
    
    @staticmethod
    def align_binary_points(values):
        """
        Aligns the binary points of 2 or more WideFix objects (e.g. to perform comparisons).
        """
        values = deep_copy(values)
        
        # Find the maximum number of frac bits
        Fmax = max(value.fmt.F for value in values)

        # Resize every input to align binary points
        for i, value in enumerate(values):
            r_fmt = FixFormat(value.fmt.S, value.fmt.I, Fmax)
            values[i] = value.resize(r_fmt)

        return values
    
    @property
    def data(self):
        """
        Returns a copy of the internal data array.
        """
        return self._data.copy()
    
    @property
    def fmt(self):
        """
        Returns a copy of the fixed-point format.
        """
        return shallow_copy(self._fmt)
    
    def to_real(self, warn=True):
        """
        Returns a human-readable (floating-point) approximation of the  WideFxp data.
        Includes boundes check to report possible loss of precision.
        """
        if warn:
            if (self.fmt.S == 1 and (np.any(self.data < -2**52) or np.any(self.data >= 2**52))) \
                or (self.fmt.S == 0 and np.any(self.data >= 2**53)):
                warnings.warn("WideFix.to_real: Possible loss of precision when converting WideFix data to float!", Warning)
        return np.array(self._data/2.0**self._fmt.F, dtype=np.float64)
    
    def to_uint64_array(self):
        """
        Packs WideFxp data into a uint64 array (e.g. for passing to MATLAB).
        Data is packed into columns, so result[:,k] corresponds to data[k].
        """
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

    def round(self, r_fmt : FixFormat, rnd : FixRound = FixRound.Trunc_s):
        """
        Returns a rounded copy (when the number of LSBs is reduced).
        """
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

    def saturate(self, r_fmt : FixFormat, sat : FixSaturate = FixSaturate.None_s):
        """
        Returns a saturated copy (when the number of MSBs is reduced).
        """
        # Copy object data so self is not modified and take floor to enforce int object type
        val = np.floor(self._data)
        
        # Saturation warning
        if sat == FixSaturate.Warn_s or sat == FixSaturate.SatWarn_s:
            if np.any(val > WideFix.max_value(r_fmt).data) or np.any(val < WideFix.min_value(r_fmt).data):
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
            val = np.where(val > WideFix.max_value(r_fmt).data, WideFix.max_value(r_fmt).data, val)
            val = np.where(val < WideFix.min_value(r_fmt).data, WideFix.min_value(r_fmt).data, val)
            
        return WideFix(val, r_fmt)

    def resize(self, r_fmt : FixFormat,
               rnd : FixRound = FixRound.Trunc_s,
               sat : FixSaturate = FixSaturate.None_s):
        """
        Returns a resized (rounded and saturated copy).
        """
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
        mid_fmt = FixFormat.ForAddsub(self._fmt, b._fmt)
        if r_fmt is None:
            r_fmt = mid_fmt
        radd = self.add(b, r_fmt, rnd, sat)
        rsub = self.sub(b, r_fmt, rnd, sat)
        r_data = np.where(add, radd._data, rsub._data)
        return WideFix(r_data, r_fmt, copy=False)

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
        
        return mid.resize(r_fmt, rnd, sat)
    
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
        a, b = WideFix.align_binary_points([self, other])
        return a._data == b._data
    
    # "!=" operator
    def __ne__(self, other):
        a, b = WideFix.align_binary_points([self, other])
        return a._data != b._data
    
    # "<" operator
    def __lt__(self, other):
        a, b = WideFix.align_binary_points([self, other])
        return a._data < b._data
    
    # "<=" operator
    def __le__(self, other):
        a, b = WideFix.align_binary_points([self, other])
        return a._data <= b._data
    
    # ">" operator
    def __gt__(self, other):
        a, b = WideFix.align_binary_points([self, other])
        return a._data > b._data
    
    # ">=" operator
    def __ge__(self, other):
        a, b = WideFix.align_binary_points([self, other])
        return a._data >= b._data
    
    # len()
    def __len__(self):
        return len(self._data)

    # Default string representations: Convert to float for consistency with "narrow" en_cl_fix_pkg.
    # Note: To print raw internal integer data, use print(x._data).
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
