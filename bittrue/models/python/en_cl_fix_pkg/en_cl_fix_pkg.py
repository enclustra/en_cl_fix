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
    # be represented exactly. In theory, this would mean: return fmt.I + fmt.F > 53.
    # However, handling wrapping of signed numbers (when saturation is disabled) is made simpler if
    # we reserve an extra integer bit for signed numbers. This gives a consistent 53-bit limit for
    # both signed and unsigned numbers.
    return cl_fix_width(fmt) > 53

def cl_fix_format_to_string(fmt : FixFormat) -> str:
    return str(fmt)

def cl_fix_max_value(rFmt : FixFormat):
    if cl_fix_is_wide(rFmt):
        return wide_fxp.MaxValue(rFmt)
    else:
        return 2.0**rFmt.I-2.0**(-rFmt.F)

def cl_fix_min_value(rFmt : FixFormat):
    if cl_fix_is_wide(rFmt):
        return wide_fxp.MinValue(rFmt)
    else:
        if rFmt.S == 1:
            return -2.0**rFmt.I
        else:
            return 0.0

def cl_fix_from_real(a, rFmt : FixFormat, saturate : FixSaturate = FixSaturate.SatWarn_s):
    
    if cl_fix_is_wide(rFmt):
        return wide_fxp.FromFloat(a, rFmt, saturate)
    else:
        # Saturation warning
        if (saturate == FixSaturate.SatWarn_s) or (saturate == FixSaturate.Warn_s):
            amax = np.max(a)
            amin = np.min(a)
            if amax > cl_fix_max_value(rFmt):
                warnings.warn(f"cl_fix_from_real: Number {amax} exceeds maximum for format {rFmt}", Warning)
            if amin < cl_fix_min_value(rFmt):
                warnings.warn(f"cl_fix_from_real: Number {amin} exceeds minimum for format {rFmt}", Warning)
        
        # Quantize. Always use half-up rounding.
        x = np.floor(a*(2.0**rFmt.F)+0.5)/2.0**rFmt.F
        
        # Saturate
        if (saturate == FixSaturate.Sat_s) or (saturate == FixSaturate.SatWarn_s):
            x = np.where(x > cl_fix_max_value(rFmt), cl_fix_max_value(rFmt), x)
            x = np.where(x < cl_fix_min_value(rFmt), cl_fix_min_value(rFmt), x)
        
        return x

def cl_fix_zeros(shape, fmt):
    return cl_fix_from_real(np.zeros(shape), fmt)

def cl_fix_from_integer(a : int, aFmt : FixFormat):
    if cl_fix_is_wide(aFmt):
        if not np.all(cl_fix_in_range(a, aFmt, aFmt)):
            raise ValueError("cl_fix_from_integer: Value not in number format range")
        return wide_fxp(a, aFmt)
    else:
        value = np.array(a/2**aFmt.F, np.float64)
        if not np.all(cl_fix_in_range(value, aFmt, aFmt)):
            raise ValueError("cl_fix_from_integer: Value not in number format range")
        return value

def cl_fix_to_integer(a, aFmt : FixFormat):
    if type(a) == wide_fxp:
        return a.data
    else:
        return np.array(np.round(a*2.0**aFmt.F),'int64')

def cl_fix_round(a, aFmt : FixFormat, rFmt : int, rnd : FixRound):
    assert rFmt == FixFormat.ForRound(aFmt, rFmt.F, rnd), "cl_fix_round: Invalid result format. Use FixFormat.ForRound()."
    
    if type(a) == wide_fxp or cl_fix_is_wide(rFmt):
        # Convert to wide_fxp (if not already wide_fxp)
        a = wide_fxp.FromFxp(a, aFmt)
        # Round
        rounded = a.round(rFmt, rnd)
        # Convert to narrow if required
        if not cl_fix_is_wide(rFmt):
            rounded = rounded.to_narrow_fxp()
    else:
        a = np.array(a)
        
        # Add offset before truncating to implement rounding
        if rFmt.F < aFmt.F:
            if rnd is FixRound.Trunc_s:
                None
            elif rnd is FixRound.NonSymPos_s:
                a = a + 2.0 ** (-rFmt.F - 1)
            elif rnd is FixRound.NonSymNeg_s:
                a = a + 2.0 ** (-rFmt.F - 1) - 2.0 ** -aFmt.F
            elif rnd is FixRound.SymInf_s:
                a = a + 2.0 ** (-rFmt.F - 1) - 2.0 ** -aFmt.F * (a < 0).astype(int)
            elif rnd is FixRound.SymZero_s:
                a = a + 2.0 ** (-rFmt.F - 1) - 2.0 ** -aFmt.F * (a >= 0).astype(int)
            elif rnd is FixRound.ConvEven_s:
                a = a + 2.0 ** (-rFmt.F - 1) - 2.0 ** -aFmt.F * ((np.floor(a * 2 ** rFmt.F) + 1) % 2)
            elif rnd is FixRound.ConvOdd_s:
                a = a + 2.0 ** (-rFmt.F - 1) - 2.0 ** -aFmt.F * ((np.floor(a * 2 ** rFmt.F)) % 2)
            else:
                raise Exception(f"cl_fix_round: Unsupported rounding mode: {rnd}")
        
        # Truncate
        rounded = np.floor(a * 2.0 ** rFmt.F).astype(float) * 2.0 ** -rFmt.F
        
    return rounded
    
def cl_fix_saturate(a, aFmt : FixFormat, rFmt : FixFormat, sat : FixSaturate):
    assert rFmt.F == aFmt.F, "cl_fix_saturate: Number of frac bits cannot change."
    
    if type(a) == wide_fxp or cl_fix_is_wide(rFmt):
        # Convert to wide_fxp (if not already wide_fxp)
        a = wide_fxp.FromFxp(a, aFmt)
        # Saturate
        saturated = a.saturate(rFmt, sat)
        # Convert to narrow if required
        if not cl_fix_is_wide(rFmt):
            saturated = saturated.to_narrow_fxp()
    else:
        # Saturation warning
        fmtMax = cl_fix_max_value(rFmt)
        fmtMin = cl_fix_min_value(rFmt)
        if sat == FixSaturate.Warn_s or sat == FixSaturate.SatWarn_s:
            if np.any(a > fmtMax) or np.any(a < fmtMin):
                warnings.warn("cl_fix_saturate : Saturation warning!", Warning)
        
        # Saturation
        if sat == FixSaturate.None_s or sat == FixSaturate.Warn_s:
            # Wrap
            
            # Decide if signed wrapping calculation will fit in narrow format
            if rFmt.S == 1:
                # We need to add: a + 2.0 ** rFmt.I.
                # For rFmt.I < 0, we increase frac bits to guarantee at least 1 bit in the format.
                if rFmt.I >= 0:
                    offsetFmt = FixFormat(0,rFmt.I+1,0)
                else:
                    offsetFmt = FixFormat(0,rFmt.I+1,-rFmt.I)
                addFmt = FixFormat.ForAdd(aFmt, offsetFmt)
                convertToWide = cl_fix_is_wide(addFmt)
            else:
                convertToWide = False
            
            if convertToWide:
                # Do intermediate calculation in wide_fxp (int) to avoid loss of precision
                a = np.floor(a.astype(object) * 2**rFmt.F)
                satSpan = 2**(rFmt.I + rFmt.F)
                if rFmt.S == 1:
                    saturated = ((a + satSpan) % (2*satSpan)) - satSpan
                else:
                    saturated = a % satSpan
                # Convert back to narrow fixed-point
                saturated = (saturated / 2**rFmt.F).astype(float)
            else:
                # Calculate in float64 without loss of precision
                if rFmt.S == 1:
                    saturated = ((a + 2.0 ** rFmt.I) % (2.0 ** (rFmt.I + 1))) - 2.0 ** rFmt.I
                else:
                    saturated = a % (2.0**rFmt.I)
        else:
            # Saturate
            saturated = np.where(a > fmtMax, fmtMax, a)
            saturated = np.where(a < fmtMin, fmtMin, saturated)
    
    return saturated
    
def cl_fix_resize(  a, aFmt : FixFormat,
                    rFmt : FixFormat,
                    rnd : FixRound = FixRound.Trunc_s, sat : FixSaturate = FixSaturate.None_s):
    # Round
    roundedFmt = FixFormat.ForRound(aFmt, rFmt.F, rnd)
    rounded = cl_fix_round(a, aFmt, roundedFmt, rnd)
    
    # Saturate
    result = cl_fix_saturate(rounded, roundedFmt, rFmt, sat)

    return result

def cl_fix_in_range(a, aFmt : FixFormat,
                    rFmt : FixFormat,
                    rnd : FixRound = FixRound.Trunc_s):
    rndFmt = FixFormat.ForRound(aFmt, rFmt.F, rnd)
    rounded = cl_fix_round(a, aFmt, rndFmt, rnd)
    lo = np.where(rounded < cl_fix_min_value(rFmt), False, True)
    hi = np.where(rounded > cl_fix_max_value(rFmt), False, True)
    return np.where(np.logical_and(lo,hi), True, False)

def cl_fix_abs( a, aFmt : FixFormat,
                rFmt : FixFormat,
                rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    midFmt = FixFormat.ForAbs(aFmt)
    aNeg = cl_fix_neg(a, aFmt, midFmt)
    aPos = cl_fix_resize(a, aFmt, midFmt)
    
    a = np.where(a < 0, aNeg, aPos)
    return cl_fix_resize(a, midFmt, rFmt, rnd, sat)

def cl_fix_neg(a, aFmt : FixFormat,
              rFmt : FixFormat,
              rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    midFmt = FixFormat.ForNeg(aFmt)
    if type(a) == wide_fxp or cl_fix_is_wide(midFmt):
        a = wide_fxp.FromFxp(a, aFmt)
    return cl_fix_resize(-a, midFmt, rFmt, rnd, sat)

def cl_fix_add( a, aFmt : FixFormat,
                b, bFmt : FixFormat,
                rFmt : FixFormat,
                rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    midFmt = FixFormat.ForAdd(aFmt, bFmt)
    if type(a) == wide_fxp or type(b) == wide_fxp or cl_fix_is_wide(midFmt):
        a = wide_fxp.FromFxp(a, aFmt)
        b = wide_fxp.FromFxp(b, bFmt)
    return cl_fix_resize(a + b, midFmt, rFmt, rnd, sat)

def cl_fix_sub( a, aFmt : FixFormat,
                b, bFmt : FixFormat,
                rFmt : FixFormat,
                rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    midFmt = FixFormat.ForSub(aFmt, bFmt)
    if type(a) == wide_fxp or type(b) == wide_fxp or cl_fix_is_wide(midFmt):
        a = wide_fxp.FromFxp(a, aFmt)
        b = wide_fxp.FromFxp(b, bFmt)
    return cl_fix_resize(a - b, midFmt, rFmt, rnd, sat)

def cl_fix_addsub(  a, aFmt : FixFormat,
                    b, bFmt : FixFormat,
                    add,    #bool or bool array
                    rFmt : FixFormat,
                    rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    radd = cl_fix_add(a, aFmt, b, bFmt, rFmt, rnd, sat)
    rsub = cl_fix_sub(a, aFmt, b, bFmt, rFmt, rnd, sat)
    return np.where(add, radd, rsub)

def cl_fix_shift(  a, aFmt : FixFormat,
                   shift : int,
                   rFmt : FixFormat,
                   rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    # Note: This function performs a lossless shift (equivalent to *2.0**shift), then resizes to
    #       the output format. The initial shift does NOT truncate any bits.
    # Note: "shift" direction is left. (So shift<0 shifts right).
    if cl_fix_is_wide(rFmt):
        a = wide_fxp.FromFxp(a, aFmt)
    if type(a) == wide_fxp:
        if np.ndim(shift) == 0:
            # Constant shift
            temp_fmt = FixFormat.ForShift(aFmt, shift)
            # Change format without changing data values => shift
            tmp = wide_fxp(a.data, temp_fmt)
            return cl_fix_resize(tmp, temp_fmt, rFmt, rnd, sat)
        else:
            # Variable shift (each value individually)
            assert np.ndim(shift) == 1, "cl_fix_shift : shift must be 0d or 1d"
            assert shift.size == a.data.size, "cl_fix_shift : shift must be 0d or the same length as a"
            r = wide_fxp(np.zeros(a.data.size, dtype=object), rFmt)
            for i, s in enumerate(shift):
                temp_fmt = FixFormat.ForShift(aFmt, s)
                # Change format without changing data values => shift
                tmp = wide_fxp._FromIntScalar(a.data[i], temp_fmt)
                # Resize to rFmt
                r._data[i] = tmp.resize(rFmt, rnd, sat).data[0]
            
            # Convert to narrow if required
            if not cl_fix_is_wide(rFmt):
                r = r.to_narrow_fxp()
            
            return r
    else:
        temp_fmt = FixFormat.ForShift(aFmt, np.min(shift), np.max(shift))
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
            fid.write(cl_fix_format_to_string(fmt) + "\n")
    
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
            xint[i] = random.randrange(fmtLo.data[0], fmtHi.data[0]+1)

        return wide_fxp(xint, fmt)
    else:
        intLo = fmtLo*2**fmt.F
        intHi = fmtHi*2**fmt.F
        xint = np.random.randint(intLo, intHi+1, (n,), 'int64')
        return (xint / 2**fmt.F).astype(float)
