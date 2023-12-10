###################################################################################################
# Copyright (c) 2023 Enclustra GmbH, Switzerland (info@enclustra.com)
###################################################################################################

###################################################################################################
# Description:
#
# The NarrowFix class provides support for ordinary "narrow" (<= 53-bit) fixed-point numbers.
#
# Internal data is simply stored in (double-precision) floats, with the proper normalization.
#
# NarrowFix executes significantly faster than the WideFix, but only supports data widths up to
# 53 bits.
###################################################################################################

import numpy as np
import warnings
from copy import copy as shallow_copy

from .en_cl_fix_types import *


class NarrowFix:
    
    # An IEEE 754 double has:
    #   * 1 explicit sign bit.
    #   * 11 exponent bits (supports -1022 to +1023 due to values reserved for special cases).
    #   * 52 fractional bits.
    #   * 1 implicit integer bit := '1'.
    # The values +0 and -0 are supported as special cases (exponent = 0x000). This means integers
    # on [-2**53, 2**53] can be represented exactly. In other words, if we assume the exponent
    # is never overflowed, then 54-bit signed numbers and 53-bit unsigned numbers are guaranteed to
    # be represented exactly. In theory, this would mean: return fmt.I + fmt.F > 53.
    # However, handling wrapping of signed numbers (when saturation is disabled) is made simpler if
    # we reserve an extra integer bit for signed numbers. This gives a consistent 53-bit limit for
    # both signed and unsigned numbers.
    MAX_WIDTH = 53
    
    def __init__(self, data, fmt : FixFormat, copy=True):
        if isinstance(data, float):
            data = np.array(data, dtype=np.float64)
        # See cl_fix_is_wide() for details on "narrow" versus "wide"
        assert fmt.width <= NarrowFix.MAX_WIDTH, "NarrowFix: Requested format is too wide. Use WideFix."
        assert data.dtype == np.float64, f"NarrowFix: requires float64 data. Got: {data.dtype}"
        if copy:
            self._data = data.copy()
        else:
            self._data = data
        # Always copy the format (very small)
        self._fmt = shallow_copy(fmt)
        
    @staticmethod
    def from_real(a, r_fmt : FixFormat, saturate : FixSaturate = FixSaturate.SatWarn_s):
        """
        Converts from floating-point to NarrowFix, with half-up rounding and saturation.
        
        Note: If a different rounding mode is needed, or if saturation is not desired, then use
        resize().
        """
        # Saturation warning
        if (saturate == FixSaturate.SatWarn_s) or (saturate == FixSaturate.Warn_s):
            amax = np.max(a)
            amin = np.min(a)
            if amax > NarrowFix.max_value(r_fmt)._data:
                warnings.warn(f"NarrowFix: Number {amax} exceeds maximum for format {r_fmt}", Warning)
            if amin < NarrowFix.min_value(r_fmt)._data:
                warnings.warn(f"NarrowFix: Number {amin} exceeds minimum for format {r_fmt}", Warning)
        
        # Quantize.
        # Always use half-up rounding (to avoid implementing all rounding modes in floating point).
        x = np.floor(a*(2.0**r_fmt.F)+0.5)/2.0**r_fmt.F
        
        # Saturate
        if (saturate == FixSaturate.Sat_s) or (saturate == FixSaturate.SatWarn_s):
            x = np.where(x > NarrowFix.max_value(r_fmt)._data, NarrowFix.max_value(r_fmt)._data, x)
            x = np.where(x < NarrowFix.min_value(r_fmt)._data, NarrowFix.min_value(r_fmt)._data, x)
        else:
            # Wrapping has not been implemented
            raise NotImplementedError(f"NarrowFix: Unsupported saturation mode {str(saturate)}")
        
        return NarrowFix(x, r_fmt, copy=False)
    
    @staticmethod
    def from_integer(a, a_fmt : FixFormat):
        """
        Converts from unnormalized integer data to NarrowFix.
        
        Example: from_integer(5, FixFormat(0, 2, 1)) = NarrowFix(2.5, FixFormat(0, 2, 1)).
        """
        value = np.array(a/2**a_fmt.F, dtype=np.float64)
        if not np.all(NarrowFix(value, a_fmt).in_range(a_fmt)):
            raise ValueError("NarrowFix.from_integer: Value not in number format range")
        return NarrowFix(value, a_fmt, copy=False)
    
    @staticmethod
    def max_value(fmt : FixFormat):
        """
        Calculates the maximum representable value for a given FixFormat.
        """
        return NarrowFix(np.array(2.0**fmt.I - 2.0**(-fmt.F)), fmt, copy=False)
    
    @staticmethod
    def min_value(fmt : FixFormat):
        """
        Calculates the minimum representable value for a given FixFormat.
        """
        min_val = -2.0**fmt.I if fmt.S == 1 else 0.0
        return NarrowFix(np.array(min_val), fmt, copy=False)
    
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
    
    def to_integer(self):
        """
        Converts from fixed-point to unnormalized integer data.
        
        Example: to_integer(2.5, FixFormat(0, 2, 1)) = 5
        """
        return np.array(np.round(self._data*2.0**self._fmt.F), dtype=np.int64)
    
    def in_range(self, r_fmt : FixFormat, rnd : FixRound = FixRound.Trunc_s):
        """
        Determines if the input values could be represented in r_fmt without saturation.
        """
        rounded_fmt = FixFormat.for_round(self._fmt, r_fmt.F, rnd)
        rounded = self.round(rounded_fmt, rnd)
        lo = np.where(rounded < NarrowFix.min_value(r_fmt), False, True)
        hi = np.where(rounded > NarrowFix.max_value(r_fmt), False, True)
        return np.where(np.logical_and(lo,hi), True, False)
    
    def round(self, r_fmt, rnd : FixRound):
        """
        Returns a rounded copy (when the number of LSBs is reduced).
        """
        assert r_fmt == FixFormat.for_round(self._fmt, r_fmt.F, rnd), "NarrowFix.round: Invalid result format. Use FixFormat.for_round()."
        
        data = self.data
        fmt = self._fmt
        
        # Add offset before truncating to implement rounding
        if r_fmt.F < fmt.F:
            if rnd is FixRound.Trunc_s:
                None
            elif rnd is FixRound.NonSymPos_s:
                data = data + 2.0 ** (-r_fmt.F - 1)
            elif rnd is FixRound.NonSymNeg_s:
                data = data + 2.0 ** (-r_fmt.F - 1) - 2.0 ** -fmt.F
            elif rnd is FixRound.SymInf_s:
                data = data + 2.0 ** (-r_fmt.F - 1) - 2.0 ** -fmt.F * (data < 0).astype(int)
            elif rnd is FixRound.SymZero_s:
                data = data + 2.0 ** (-r_fmt.F - 1) - 2.0 ** -fmt.F * (data >= 0).astype(int)
            elif rnd is FixRound.ConvEven_s:
                data = data + 2.0 ** (-r_fmt.F - 1) - 2.0 ** -fmt.F * ((np.floor(data * 2 ** r_fmt.F) + 1) % 2)
            elif rnd is FixRound.ConvOdd_s:
                data = data + 2.0 ** (-r_fmt.F - 1) - 2.0 ** -fmt.F * ((np.floor(data * 2 ** r_fmt.F)) % 2)
            else:
                raise ValueError(f"NarrowFix.round: Unsupported rounding mode: {rnd}")
        
        # Truncate
        data = np.floor(data * 2.0 ** r_fmt.F).astype(np.float64) * 2.0 ** -r_fmt.F
            
        return NarrowFix(data, r_fmt, copy=False)
    
    def saturate(self, r_fmt : FixFormat, sat : FixSaturate):
        """
        Returns a saturated copy (when the number of MSBs is reduced).
        """
        data = self.data
        fmt = self._fmt
        
        assert r_fmt.F == fmt.F, "NarrowFix.saturate: Number of frac bits cannot change."
        
        # Saturation warning
        fmt_max = NarrowFix.max_value(r_fmt)
        fmt_min = NarrowFix.min_value(r_fmt)
        if sat == FixSaturate.Warn_s or sat == FixSaturate.SatWarn_s:
            if np.any(self > fmt_max) or np.any(self < fmt_min):
                warnings.warn("NarrowFix.saturate : Saturation warning!", Warning)
        
        # Saturation
        if sat == FixSaturate.None_s or sat == FixSaturate.Warn_s:
            # Wrap
            
            # Decide if signed wrapping calculation will fit in narrow format
            if r_fmt.S == 1:
                # We need to add: data + 2.0 ** r_fmt.I.
                # For r_fmt.I < 0, we increase frac bits to guarantee at least 1 bit in the format.
                if r_fmt.I >= 0:
                    offset_fmt = FixFormat(0,r_fmt.I+1,0)
                else:
                    offset_fmt = FixFormat(0,r_fmt.I+1,-r_fmt.I)
                add_fmt = FixFormat.for_add(fmt, offset_fmt)
                convert_to_wide = (add_fmt.width > NarrowFix.MAX_WIDTH)
            else:
                convert_to_wide = False
            
            if convert_to_wide:
                # Do intermediate calculation in WideFix (int) to avoid loss of precision
                data = np.floor(data.astype(object) * 2**r_fmt.F)
                span = 2**(r_fmt.I + r_fmt.F)
                if r_fmt.S == 1:
                    sat_data = ((data + span) % (2*span)) - span
                else:
                    sat_data = data % span
                # Convert back to narrow fixed-point
                sat_data = (sat_data / 2**r_fmt.F).astype(float)
            else:
                # Calculate in float64 without loss of precision
                if r_fmt.S == 1:
                    sat_data = ((data + 2.0 ** r_fmt.I) % (2.0 ** (r_fmt.I + 1))) - 2.0 ** r_fmt.I
                else:
                    sat_data = data % (2.0**r_fmt.I)
        else:
            # Saturate
            sat_data = np.where(self > fmt_max, fmt_max._data, data)
            sat_data = np.where(self < fmt_min, fmt_min._data, sat_data)
        
        return NarrowFix(sat_data, r_fmt, copy=False)

    def resize(self, r_fmt : FixFormat, rnd : FixRound = FixRound.Trunc_s, sat : FixSaturate = FixSaturate.None_s):
        """
        Returns a resized (rounded and saturated copy).
        """
        # Round
        rounded_fmt = FixFormat.for_round(self._fmt, r_fmt.F, rnd)
        rounded = self.round(rounded_fmt, rnd)
        
        # Saturate
        return rounded.saturate(r_fmt, sat)

    def abs(self, r_fmt : FixFormat = None, rnd : FixRound = FixRound.Trunc_s, sat : FixSaturate = FixSaturate.None_s):
        """
        Calculates absolute values, abs(self).
        """
        mid_fmt = FixFormat.for_abs(self._fmt)
        if r_fmt is None:
            r_fmt = mid_fmt
        neg = self.neg(mid_fmt)
        pos = self.resize(mid_fmt)
        
        data_abs = np.where(self._data < 0, neg._data, pos._data)
        return NarrowFix(data_abs, mid_fmt, copy=False).resize(r_fmt, rnd, sat)

    def neg(self, r_fmt : FixFormat = None, rnd : FixRound = FixRound.Trunc_s, sat : FixSaturate = FixSaturate.None_s):
        """
        Calculates negation, -self.
        """
        mid_fmt = FixFormat.for_neg(self._fmt)
        if r_fmt is None:
            r_fmt = mid_fmt
        return NarrowFix(-self._data, mid_fmt, copy=False).resize(r_fmt, rnd, sat)

    def add(self, b : "NarrowFix",
            r_fmt : FixFormat = None,
            rnd : FixRound = FixRound.Trunc_s, sat : FixSaturate = FixSaturate.None_s):
        """
        Calculates addition, self + b.
        """
        mid_fmt = FixFormat.for_add(self._fmt, b._fmt)
        if r_fmt is None:
            r_fmt = mid_fmt
        return NarrowFix(self._data + b._data, mid_fmt, copy=False).resize(r_fmt, rnd, sat)

    def sub(self, b : "NarrowFix",
            r_fmt : FixFormat = None,
            rnd : FixRound = FixRound.Trunc_s, sat : FixSaturate = FixSaturate.None_s):
        """
        Calculates subtraction, self - b.
        """
        mid_fmt = FixFormat.for_sub(self._fmt, b._fmt)
        if r_fmt is None:
            r_fmt = mid_fmt
        return NarrowFix(self._data - b._data, mid_fmt, copy=False).resize(r_fmt, rnd, sat)

    def addsub(self, b : "NarrowFix", add,  # Bool or bool array.
               r_fmt : FixFormat = None,
               rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
        """
        Calculates addition/subtraction:
            self + b, where add == True.
            self - b, where add == False.
        """
        mid_fmt = FixFormat.for_addsub(self._fmt, b._fmt)
        if r_fmt is None:
            r_fmt = mid_fmt
        radd = self.add(b, r_fmt, rnd, sat)
        rsub = self.sub(b, r_fmt, rnd, sat)
        r_data = np.where(add, radd._data, rsub._data)
        return NarrowFix(r_data, r_fmt, copy=False)

    def mult(self, b : "NarrowFix",
             r_fmt : FixFormat = None,
             rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
        """
        Calculates multiplication, self * b.
        """
        mid_fmt = FixFormat.for_mult(self._fmt, b._fmt)
        if r_fmt is None:
            r_fmt = mid_fmt
        return NarrowFix(self._data * b._data, mid_fmt, copy=False).resize(r_fmt, rnd, sat)

    def shift(self, shift,
              r_fmt : FixFormat = None,
              rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
        """
        Calculates a left bit-shift (equivalent to *2.0**shift). To shift right, set shift < 0.
        
        Note: This function performs a lossless shift (equivalent to *2.0**shift), then resizes to the
        output format. The initial shift does NOT truncate any bits.
        """
        
        mid_fmt = FixFormat.for_shift(self._fmt, np.min(shift), np.max(shift))
        if r_fmt is None:
            r_fmt = mid_fmt
        return NarrowFix(self._data * 2.0 ** shift, mid_fmt, copy=False).resize(r_fmt, rnd, sat)
    
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
    
    def __lshift__(self, n):
        return self.shift(n)
    
    # "==" operator
    def __eq__(self, other):
        assert isinstance(other, NarrowFix), "NarrowFix can only be compared with NarrowFix. Try _data."
        return self._data == other._data
    
    # "!=" operator
    def __ne__(self, other):
        assert isinstance(other, NarrowFix), "NarrowFix can only be compared with NarrowFix. Try _data."
        return self._data != other._data
    
    # "<" operator
    def __lt__(self, other):
        assert isinstance(other, NarrowFix), "NarrowFix can only be compared with NarrowFix. Try _data."
        return self._data < other._data
    
    # "<=" operator
    def __le__(self, other):
        assert isinstance(other, NarrowFix), "NarrowFix can only be compared with NarrowFix. Try _data."
        return self._data <= other._data
    
    # ">" operator
    def __gt__(self, other):
        assert isinstance(other, NarrowFix), "NarrowFix can only be compared with NarrowFix. Try _data."
        return self._data > other._data
    
    # ">=" operator
    def __ge__(self, other):
        assert isinstance(other, NarrowFix), "NarrowFix can only be compared with NarrowFix. Try _data."
        return self._data >= other._data
    
    # len()
    def __len__(self):
        assert isinstance(other, NarrowFix), "NarrowFix can only be compared with NarrowFix. Try _data."
        return len(self._data)
    
    def __repr__(self):
        return (
            "NarrowFix: " + repr(self._fmt) + "\n"
            + repr(self._data)
        )
    
    def __str__(self):
        return (
            f"NarrowFix: {self._fmt}\n"
            f"{self._data}"
        )
