########################################################################################################################
#  Copyright (c) 2018 by Paul Scherrer Institute, Switzerland
#  All rights reserved.
#  Authors: Oliver Bruendler
########################################################################################################################

########################################################################################################################
# Imports
########################################################################################################################
import numpy as np
import warnings
import random

from .en_cl_fix_types import *
from .wide_fxp import wide_fxp

########################################################################################################################
# Bittrue available in VHDL
########################################################################################################################
def cl_fix_width(fmt : FixFormat) -> int:
    return fmt.width()

def cl_fix_is_wide(fmt : FixFormat) -> bool:
    # Determine whether "narrow" (double precision float) or "wide" (arbitrary-precision integer)
    # fixed-point representation should be used for this fixed-point format.
    # An IEEE 754 double has:
    #   * 1 explicit sign bit.
    #   * 11 exponent bits (supports -1022 to +1023 due to values reserved for special cases).
    #   * 52 fractional bits.
    #   * 1 implicit integer bit := '1'.
    # The values +0 and -0 are supported as special cases (exponent = 0x000). This means integers
    # on [-2**53, 2**53] can be represented exactly. In other words, if we assume the exponent
    # is never overflowed, then 54-bit signed numbers and 53-bit unsigned numbers are guaranteed to
    # be represented exactly. In theory, this would mean: return fmt.IntBits + fmt.FracBits > 53.
    # However, handling wrapping of signed numbers (when saturation is disabled) is made simpler if
    # we reserve an extra integer bit for signed numbers. This gives a consistent 53-bit limit for
    # both signed and unsigned numbers.
    return cl_fix_width(fmt) > 53

def cl_fix_string_from_format(fmt : FixFormat) -> str:
    return str(fmt)

def cl_fix_max_value(rFmt : FixFormat):
    if cl_fix_is_wide(rFmt):
        return wide_fxp.MaxValue(rFmt)
    else:
        return 2.0**rFmt.IntBits-2.0**(-rFmt.FracBits)

def cl_fix_min_value(rFmt : FixFormat):
    if cl_fix_is_wide(rFmt):
        return wide_fxp.MinValue(rFmt)
    else:
        if rFmt.Signed:
            return -2.0**rFmt.IntBits
        else:
            return 0.0

def cl_fix_sign(a, aFmt : FixFormat):
    if not aFmt.Signed:
        return 0
    else:
        return np.where(a < 0, 1, 0)

def cl_fix_int(a, aFmt : FixFormat):
    # Extract the integer part of the data values.
    if type(a) == wide_fxp:
        r = a.floor()
        # Handle truncation to narrow representation.
        if cl_fix_is_wide(r.fmt):
            return r
        else:
            return r.to_narrow_fxp()
    else:
        rFmt = FixFormat(aFmt.Signed, aFmt.IntBits, 0)
        r = np.floor(a)
        # Handle expansion to wide_fxp (FracBits < 0).
        if cl_fix_is_wide(rFmt):
            return wide_fxp.FromNarrowFxp(r, rFmt)
        else:
            return r

def cl_fix_frac(a, aFmt : FixFormat):
    # Extract the fractional part of the data values.
    # Note: Result has implicit frac bits if IntBits<0.
    if type(a) == wide_fxp:
        r = a.frac_part()
        
        # Handle truncation to narrow representation.
        if cl_fix_is_wide(r.fmt):
            return r
        else:
            return r.to_narrow_fxp()
    else:
        if aFmt.Signed and aFmt.FracBits > 53:
            warnings.warn("cl_fix_frac : Possible loss of precision. Consider using wide_fxp.", Warning)
        
        # Drop the sign bit
        if aFmt.Signed:
            offset = 2**aFmt.IntBits
            a = np.where(a < 0, a + offset, a)
        
        # Retain fractional LSBs
        return a % 2**min(aFmt.IntBits, 0)
        
def cl_fix_combine(sign : int, intbits : int, fracbits : int, rFmt : FixFormat):
    # Combines separate {sign_bit, integer_part, fractional_part} into a fixed-point number.
    # For example: combine(0, 5, 1, FixFormat(True, 4, 2)) <==> 5.25
    if cl_fix_is_wide(rFmt):
        val = -sign*2**(rFmt.IntBits+rFmt.FracBits) + intbits*2**rFmt.FracBits + fracbits
        return wide_fxp(val, rFmt)
    else:
        return -sign*2.0**rFmt.IntBits + intbits + fracbits*2.0**-rFmt.FracBits

def cl_fix_get_msb(a, aFmt : FixFormat, index : int):
    if type(a) == wide_fxp:
        return a.get_msb(index)
    else:
        if np.ndim(a) == 0:
            a = np.array(a, ndmin=1)
        if aFmt.Signed:
            if index == 0:
                return (a < 0).astype(int)
            else:
                return ((a * 2.0 ** (index - aFmt.IntBits - 1)) % 1 >= 0.5).astype(int)
        else:
            return ((a * 2.0 ** (index - aFmt.IntBits)) % 1 >= 0.5).astype(int)

def cl_fix_get_lsb(a, aFmt : FixFormat, index : int):
    return cl_fix_get_msb(a, aFmt, cl_fix_width(aFmt)-1-index)

def cl_fix_set_msb(a, aFmt : FixFormat, index : int, value):
    if type(a) == wide_fxp:
        return a.set_msb(index, value)
    else:
        if np.any(value > 1) or np.any(value < 0):
            raise Exception("cl_fix_set_msb: only 1 and 0 allowed for value")
        value = int(value)
        current = cl_fix_get_msb(a, aFmt, index)
        if aFmt.Signed:
            if index == 0:
                return ((value - 0.5) - (current - 0.5)) * -2.0 ** (aFmt.IntBits) + a
            else:
                return ((value - 0.5) - (current - 0.5)) * 2.0 ** (aFmt.IntBits - index) + a
        else:
            return ((value - 0.5) - (current - 0.5)) * 2.0 ** (aFmt.IntBits - index - 1) + a

def cl_fix_set_lsb(a, aFmt : FixFormat, index : int, value):
    return cl_fix_set_msb(a, aFmt, cl_fix_width(aFmt)-1-index, value)

def cl_fix_from_real(a, rFmt : FixFormat, saturate : FixSaturate = FixSaturate.SatWarn_s):
    
    if cl_fix_is_wide(rFmt):
        return wide_fxp.FromFloat(a, rFmt, saturate)
    else:
        if np.ndim(a) == 0:
            a = np.array(a, ndmin=1)
        
        # Saturation warning
        if (saturate == FixSaturate.SatWarn_s) or (saturate == FixSaturate.Warn_s):
            amax = a.max()
            amin = a.min()
            if amax > cl_fix_max_value(rFmt):
                warnings.warn(f"cl_fix_from_real: Number {amax} exceeds maximum for format {rFmt}", Warning)
            if amin < cl_fix_min_value(rFmt):
                warnings.warn(f"cl_fix_from_real: Number {amin} exceeds minimum for format {rFmt}", Warning)
        
        # Quantize. Always use half-up rounding.
        x = np.floor(a*(2.0**rFmt.FracBits)+0.5)/2.0**rFmt.FracBits
        
        # Saturate
        if (saturate == FixSaturate.Sat_s) or (saturate == FixSaturate.SatWarn_s):
            x = np.where(x > cl_fix_max_value(rFmt), cl_fix_max_value(rFmt), x)
            x = np.where(x < cl_fix_min_value(rFmt), cl_fix_min_value(rFmt), x)
        
        return x

def cl_fix_from_bits_as_int(a : int, aFmt : FixFormat):
    if cl_fix_is_wide(aFmt):
        if not np.all(cl_fix_in_range(a, aFmt, aFmt)):
            raise ValueError("cl_fix_from_bits_as_int: Value not in number format range")
        return wide_fxp(a, aFmt)
    else:
        value = np.array(a/2**aFmt.FracBits, np.float64)
        if not np.all(cl_fix_in_range(value, aFmt, aFmt)):
            raise ValueError("cl_fix_from_bits_as_int: Value not in number format range")
        return value

def cl_fix_get_bits_as_int(a, aFmt : FixFormat):
    if type(a) == wide_fxp:
        return a.data
    else:
        return np.array(np.round(a*2.0**aFmt.FracBits),'int64')

def cl_fix_resize(  a, aFmt : FixFormat,
                    rFmt : FixFormat,
                    rnd : FixRound = FixRound.Trunc_s, sat : FixSaturate = FixSaturate.None_s):
    if type(a) == wide_fxp or cl_fix_is_wide(rFmt):
        # Convert to wide_fxp (if not already wide_fxp)
        a = wide_fxp.FromFxp(a, aFmt)
        # Resize
        result = a.resize(rFmt, rnd, sat)
        # Convert to narrow if required
        if not cl_fix_is_wide(rFmt):
            result = result.to_narrow_fxp()
    else:
        if np.ndim(a) == 0:
            a = np.array(a, ndmin=1)
        # Rounding
        bitGrowth = 0
        if rFmt.FracBits < aFmt.FracBits:
            if rnd is FixRound.Trunc_s:
                # No offset is applied, so no bit-growth
                bitGrowth = 0
            elif rnd is FixRound.NonSymPos_s:
                a = a + 2.0 ** (-rFmt.FracBits - 1)
                bitGrowth = 1
            elif rnd is FixRound.NonSymNeg_s:
                a = a + 2.0 ** (-rFmt.FracBits - 1) - 2.0 ** -aFmt.FracBits
                bitGrowth = 1
            elif rnd is FixRound.SymInf_s:
                a = a + 2.0 ** (-rFmt.FracBits - 1) - 2.0 ** -aFmt.FracBits * (a < 0).astype(int)
                bitGrowth = 1
            elif rnd is FixRound.SymZero_s:
                a = a + 2.0 ** (-rFmt.FracBits - 1) - 2.0 ** -aFmt.FracBits * (a >= 0).astype(int)
                bitGrowth = 1
            elif rnd is FixRound.ConvEven_s:
                a = a + 2.0 ** (-rFmt.FracBits - 1) - 2.0 ** -aFmt.FracBits * ((np.floor(a * 2 ** rFmt.FracBits) + 1) % 2)
                bitGrowth = 1
            elif rnd is FixRound.ConvOdd_s:
                a = a + 2.0 ** (-rFmt.FracBits - 1) - 2.0 ** -aFmt.FracBits * ((np.floor(a * 2 ** rFmt.FracBits)) % 2)
                bitGrowth = 1
            else:
                raise Exception("cl_fix_resize : Illegal value for round!")
        # The format after rounding is the same as after a (lossy) right shift by (aFmt.FracBits - rFmt.FracBits), but
        # with +bitGrowth (integer bit) to support the rounding offset applied above.
        roundedFmt = FixFormat(aFmt.Signed, aFmt.IntBits - (aFmt.FracBits - rFmt.FracBits) + bitGrowth, rFmt.FracBits)
        rounded = np.floor(a * 2.0 ** rFmt.FracBits).astype(float) * 2.0 ** -rFmt.FracBits

        # Saturation warning
        fmtMax = cl_fix_max_value(rFmt)
        fmtMin = cl_fix_min_value(rFmt)
        if sat == FixSaturate.Warn_s or sat == FixSaturate.SatWarn_s:
            if np.any(rounded > fmtMax) or np.any(rounded < fmtMin):
                warnings.warn("cl_fix_resize : Saturation warning!", Warning)

        # Saturation
        if sat == FixSaturate.None_s or sat == FixSaturate.Warn_s:
            # Wrap
            
            # Decide if signed wrapping calculation will fit in narrow format
            if rFmt.Signed:
                # We need to add: rounded + 2.0 ** rFmt.IntBits
                offsetFmt = FixFormat(0,rFmt.IntBits+1,0)  # Format of 2.0 ** rFmt.IntBits.
                addFmt = FixFormat.ForAdd(roundedFmt, offsetFmt)
                convertToWide = cl_fix_is_wide(addFmt)
            else:
                convertToWide = False
            
            if convertToWide:
                # Do intermediate calculation in wide_fxp (int) to avoid loss of precision
                rounded = np.floor(rounded.astype(object) * 2**rFmt.FracBits)
                satSpan = 2**(rFmt.IntBits + rFmt.FracBits)
                if rFmt.Signed:
                    result = ((rounded + satSpan) % (2*satSpan)) - satSpan
                else:
                    result = rounded % satSpan
                # Convert back to narrow fixed-point
                result = (result / 2**rFmt.FracBits).astype(float)
            else:
                # Calculate in float64 without loss of precision
                if rFmt.Signed:
                    result = ((rounded + 2.0 ** rFmt.IntBits) % (2.0 ** (rFmt.IntBits + 1))) - 2.0 ** rFmt.IntBits
                else:
                    result = rounded % (2.0**rFmt.IntBits)
        else:
            # Saturate
            result = np.where(rounded > fmtMax, fmtMax, rounded)
            result = np.where(rounded < fmtMin, fmtMin, result)

    return result

def cl_fix_in_range(    a, aFmt : FixFormat,
                        rFmt : FixFormat,
                        rnd: FixRound = FixRound.Trunc_s):
    rndFmt = FixFormat(aFmt.Signed, aFmt.IntBits+1, rFmt.FracBits)
    valRnd = cl_fix_resize(a, aFmt, rndFmt, rnd, FixSaturate.Sat_s)
    lo = np.where(valRnd < cl_fix_min_value(rFmt), False, True)
    hi = np.where(valRnd > cl_fix_max_value(rFmt), False, True)
    return np.where(np.logical_and(lo,hi), True, False)

def cl_fix_abs( a, aFmt : FixFormat,
                rFmt : FixFormat,
                rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    midFmt = FixFormat.ForNeg(aFmt)
    aNeg = cl_fix_neg(a, aFmt, midFmt)
    aPos = cl_fix_resize(a, aFmt, midFmt)
    
    a = np.where(a < 0, aNeg, aPos)
    return cl_fix_resize(a, midFmt, rFmt, rnd, sat)

def cl_fix_sabs(a, aFmt : FixFormat,
                rFmt : FixFormat,
                rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    return cl_fix_sneg(a, aFmt, a < 0, rFmt, rnd, sat)

def cl_fix_neg(a, aFmt : FixFormat,
              rFmt : FixFormat,
              rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    midFmt = FixFormat.ForNeg(aFmt)
    if type(a) == wide_fxp or cl_fix_is_wide(midFmt):
        a = wide_fxp.FromFxp(a, aFmt)
    else:
        a = cl_fix_resize(a, aFmt, midFmt)
    
    return cl_fix_resize(-a, midFmt, rFmt, rnd, sat)

def cl_fix_sneg(a, aFmt : FixFormat,
                enable : bool,
                rFmt : FixFormat,
                rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    if np.ndim(enable) == 0:
        enable = np.array(enable, ndmin=1)
    temp_fmt = FixFormat(True, aFmt.IntBits, max(aFmt.FracBits, rFmt.FracBits))
    temp = cl_fix_resize(a, aFmt, temp_fmt, FixRound.Trunc_s, FixSaturate.None_s)
    if type(temp) == wide_fxp:
        temp = -(enable.astype(int)) + (-1) ** enable.astype(int)*temp.data
        temp = wide_fxp(temp, temp_fmt)
    else:
        temp = -(enable.astype(int))*2 ** -temp_fmt.FracBits + (-1.0) ** enable.astype(int)*temp
        temp = temp.astype(float)
    return cl_fix_resize(temp, temp_fmt, rFmt, rnd, sat)

def cl_fix_add( a, aFmt : FixFormat,
                b, bFmt : FixFormat,
                rFmt : FixFormat,
                rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    midFmt = FixFormat.ForAdd(aFmt, bFmt)
    if type(a) == wide_fxp or type(b) == wide_fxp or cl_fix_is_wide(midFmt):
        a = wide_fxp.FromFxp(a, aFmt)
        b = wide_fxp.FromFxp(b, bFmt)
    else:
        a = cl_fix_resize(a, aFmt, midFmt)
        b = cl_fix_resize(b, bFmt, midFmt)
    
    return cl_fix_resize(a + b, midFmt, rFmt, rnd, sat)

def cl_fix_sub( a, aFmt : FixFormat,
                b, bFmt : FixFormat,
                rFmt : FixFormat,
                rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    midFmt = FixFormat.ForSub(aFmt, bFmt)
    if type(a) == wide_fxp or type(b) == wide_fxp or cl_fix_is_wide(midFmt):
        a = wide_fxp.FromFxp(a, aFmt)
        b = wide_fxp.FromFxp(b, bFmt)
    else:
        a = cl_fix_resize(a, aFmt, midFmt)
        b = cl_fix_resize(b, bFmt, midFmt)
    
    return cl_fix_resize(a - b, midFmt, rFmt, rnd, sat)

def cl_fix_addsub(  a, aFmt : FixFormat,
                    b, bFmt : FixFormat,
                    add,    #bool or bool array
                    rFmt : FixFormat,
                    rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    radd = cl_fix_add(a, aFmt, b, bFmt, rFmt, rnd, sat)
    rsub = cl_fix_sub(a, aFmt, b, bFmt, rFmt, rnd, sat)
    return np.where(add, radd, rsub)

def cl_fix_saddsub( a, aFmt : FixFormat,
                    b, bFmt : FixFormat,
                    add,    #bool or bool array
                    rFmt : FixFormat,
                    rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    if type(a) == wide_fxp or type(b) == wide_fxp:
        # TODO
        raise NotImplementedError()
    else:
        temp_fmt = FixFormat.ForAdd(aFmt, bFmt)
        notAdd = np.array(np.logical_not(add),dtype="int32")
        temp = a + (-1.0) ** notAdd * b - notAdd * 2.0 ** -temp_fmt.FracBits
        return cl_fix_resize(temp, temp_fmt, rFmt, rnd, sat)

def cl_fix_mean(a, aFmt : FixFormat,
                b, bFmt : FixFormat,
                rFmt : FixFormat,
                rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    temp_fmt = FixFormat.ForAdd(aFmt, bFmt)
    temp = cl_fix_add(a, aFmt, b, bFmt, temp_fmt, FixRound.Trunc_s, FixSaturate.None_s)
    return cl_fix_shift(temp, temp_fmt, -1, rFmt, rnd, sat)

def cl_fix_mean_angle(  a, aFmt : FixFormat,
                        b, bFmt : FixFormat,
                        precise : bool,
                        rFmt : FixFormat,
                        rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    raise NotImplementedError()

def cl_fix_shift(  a, aFmt : FixFormat,
                   shift : int,
                   rFmt : FixFormat,
                   rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    # Note: This function performs a lossless shift (equivalent to *2.0**shift), then resizes to
    #       the output format. The initial shift does NOT truncate any bits.
    # Note: "shift" direction is left. (So shift<0 shifts right).
    if cl_fix_is_wide(rFmt):
        a = wide_fxp.FromFxp(a, aFmt)
    temp_fmt = FixFormat.ForShift(aFmt, shift)
    if type(a) == wide_fxp:
        # Change format without changing data values => shift
        tmp = wide_fxp(a.data, temp_fmt)
        return cl_fix_resize(tmp, temp_fmt, rFmt, rnd, sat)
    else:
        return cl_fix_resize(a * 2.0 ** shift, temp_fmt, rFmt, rnd, sat)

def cl_fix_mult(    a, aFmt : FixFormat,
                    b, bFmt : FixFormat,
                    rFmt : FixFormat,
                    rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    midFmt = FixFormat.ForMult(aFmt, bFmt)
    if type(a) == wide_fxp or type(b) == wide_fxp or cl_fix_is_wide(midFmt):
        a = wide_fxp.FromFxp(a, aFmt)
        b = wide_fxp.FromFxp(b, bFmt)
    
    return cl_fix_resize(a * b, midFmt, rFmt, rnd, sat)

########################################################################################################################
# File I/O
########################################################################################################################

def cl_fix_write_formats(fmts, names, filename):

    with open(filename, "w") as fid:
        # Write header
        header = "# " + ",".join(names)
        fid.write(header + "\n")
        
        # Allow input to be a scalar fmt
        if np.ndim(fmts) == 0:
            fmts = np.array(fmts, ndmin=1)
        
        for fmt in fmts:
            fid.write(cl_fix_string_from_format(fmt) + "\n")
    
########################################################################################################################
# Simulation utility functions (not available in VHDL)
########################################################################################################################

def cl_fix_random(n : int, fmt : FixFormat):
    # Generate n random data values, distributed across the whole dynamic range of fmt.
    fmtLo = cl_fix_min_value(fmt)
    fmtHi = cl_fix_max_value(fmt)
    if cl_fix_is_wide(fmt):
        xint = np.empty((n,), dtype=object)
        for i in range(n):
            xint[i] = random.randrange(fmtLo.data, fmtHi.data+1)

        return wide_fxp(xint, fmt)
    else:
        intLo = fmtLo*2**fmt.FracBits
        intHi = fmtHi*2**fmt.FracBits
        xint = np.random.randint(intLo, intHi+1, (n,), 'int64')
        return (xint / 2**fmt.FracBits).astype(float)
