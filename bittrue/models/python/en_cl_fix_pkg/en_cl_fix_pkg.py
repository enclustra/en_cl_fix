###################################################################################################
# Copyright (c) 2023 Enclustra GmbH, Switzerland (info@enclustra.com)
###################################################################################################

###################################################################################################
# Imports
###################################################################################################
import numpy as np
import warnings
import random

from .en_cl_fix_types import *
from .wide_fix import WideFix
from .narrow_fix import NarrowFix

###################################################################################################
# Private helpers
###################################################################################################

def _clean_input(a):
    """
    Private method that ensures input data arrays are converted to np.ndarray.
    
    This is useful, for example, for data that is passed from MATLAB.
    """
    # Note: It is easier to handle this type conversion in Python because that allows each MATLAB
    # function call to just pass varargin{:} without worrying about which inputs are data.
    if hasattr(a, "__getitem__"):
        return np.array(a)
    return a

###################################################################################################
# Bit-true methods (available in VHDL)
###################################################################################################
def cl_fix_width(fmt : FixFormat) -> int:
    """
    Returns the bit-width of a fixed-point format.
    """
    return fmt.width


def cl_fix_is_wide(fmt : FixFormat) -> bool:
    """
    Determines whether "narrow" (double precision float) or "wide" (arbitrary-precision integer)
    fixed-point representation should be used for this fixed-point format.
    An IEEE 754 double has:
      * 1 explicit sign bit.
      * 11 exponent bits (supports -1022 to +1023 due to values reserved for special cases).
      * 52 fractional bits.
      * 1 implicit integer bit := '1'.
    The values +0 and -0 are supported as special cases (exponent = 0x000). This means integers
    on [-2**53, 2**53] can be represented exactly. In other words, if we assume the exponent
    is never overflowed, then 54-bit signed numbers and 53-bit unsigned numbers are guaranteed to
    be represented exactly. In theory, this would mean: return fmt.I + fmt.F > 53.
    However, handling wrapping of signed numbers (when saturation is disabled) is made simpler if
    we reserve an extra integer bit for signed numbers. This gives a consistent 53-bit limit for
    both signed and unsigned numbers.
    """
    return cl_fix_width(fmt) > 53


def cl_fix_max_value(r_fmt : FixFormat):
    """
    Returns the maximum representable value in a specific fixed-point format.
    """
    if cl_fix_is_wide(r_fmt):
        return WideFix.max_value(r_fmt)._data
    else:
        return NarrowFix.max_value(r_fmt)._data


def cl_fix_min_value(r_fmt : FixFormat):
    """
    Returns the minimum representable value in a specific fixed-point format.
    """
    if cl_fix_is_wide(r_fmt):
        return WideFix.min_value(r_fmt)._data
    else:
        return NarrowFix.min_value(r_fmt)._data


def cl_fix_from_real(a, r_fmt : FixFormat, saturate : FixSaturate = FixSaturate.SatWarn_s):
    """
    Converts from floating-point to fixed-point with half-up rounding and saturation.
    
    Note: If a different rounding mode is needed, or if saturation is not desired, then use
    cl_fix_resize.
    """
    a = _clean_input(a)
    
    if cl_fix_is_wide(r_fmt):
        return WideFix.from_real(a, r_fmt, saturate)._data
    else:
        return NarrowFix.from_real(a, r_fmt, saturate)._data


def cl_fix_from_integer(a, a_fmt : FixFormat):
    """
    Converts from unnormalized integer data to fixed-point.
    
    Example: cl_fix_from_integer(5, FixFormat(0, 2, 1)) = 2.5
    """
    a = _clean_input(a)
    
    if cl_fix_is_wide(a_fmt):
        return a
    else:
        return NarrowFix.from_integer(a, a_fmt)._data


def cl_fix_to_integer(a, a_fmt : FixFormat):
    """
    Converts from fixed-point to unnormalized integer data.
    
    Example: cl_fix_to_integer(2.5, FixFormat(0, 2, 1)) = 5
    """
    a = _clean_input(a)
    
    if cl_fix_is_wide(a_fmt):
        return a
    else:
        return NarrowFix(a, a_fmt, copy=False).to_integer()


def cl_fix_round(a, a_fmt : FixFormat, r_fmt : int, rnd : FixRound):
    """
    Performs rounding (when the number of fractional bits is being reduced).
    """
    assert r_fmt == cl_fix_round_fmt(a_fmt, r_fmt.F, rnd), "cl_fix_round: Invalid result format. Use cl_fix_round_fmt()."
    a = _clean_input(a)
    
    a_wide = cl_fix_is_wide(a_fmt)
    r_wide = cl_fix_is_wide(r_fmt)
    
    if a_wide or r_wide:
        # WideFix
        a = WideFix(a, a_fmt) if a_wide else WideFix.from_narrowfix(a, a_fmt)
        # Round
        r = a.round(r_fmt, rnd)
        # Convert to narrow if required
        if not r_wide:
            r = NarrowFix(r.to_real(), r_fmt)
    else:
        # NarrowFix
        r = NarrowFix(a, a_fmt, copy=False).round(r_fmt, rnd)
    
    return r._data


def cl_fix_saturate(a, a_fmt : FixFormat, r_fmt : FixFormat, sat : FixSaturate):
    """
    Performs saturation (when the number of integer/sign bits is being reduced).
    """
    assert r_fmt.F == a_fmt.F, "cl_fix_saturate: Number of frac bits cannot change."
    a = _clean_input(a)
    
    a_wide = cl_fix_is_wide(a_fmt)
    r_wide = cl_fix_is_wide(r_fmt)
    
    if a_wide or r_wide:
        # WideFix
        a = WideFix(a, a_fmt) if a_wide else WideFix.from_narrowfix(a, a_fmt)
        # Saturate
        r = a.saturate(r_fmt, sat)
        # Convert to narrow
        if not r_wide:
            r = NarrowFix(r.to_real(), r_fmt)
    else:
        # NarrowFix
        r = NarrowFix(a, a_fmt, copy=False).saturate(r_fmt, sat)
    
    return r._data


def cl_fix_resize(a, a_fmt : FixFormat,
                  r_fmt : FixFormat,
                  rnd : FixRound = FixRound.Trunc_s, sat : FixSaturate = FixSaturate.None_s):
    """
    Resizes data values (with rounding, then saturation) to fit a new fixed-point format.
    """
    # Round
    rounded_fmt = FixFormat.ForRound(a_fmt, r_fmt.F, rnd)
    rounded = cl_fix_round(a, a_fmt, rounded_fmt, rnd)
    
    # Saturate
    result = cl_fix_saturate(rounded, rounded_fmt, r_fmt, sat)

    return result


def cl_fix_in_range(a, a_fmt : FixFormat,
                    r_fmt : FixFormat,
                    rnd : FixRound = FixRound.Trunc_s):
    """
    Determines if the input values could be represented in r_fmt without saturation.
    """
    rounded_fmt = FixFormat.ForRound(a_fmt, r_fmt.F, rnd)
    rounded = cl_fix_round(a, a_fmt, rounded_fmt, rnd)
    lo = np.where(rounded < cl_fix_min_value(r_fmt), False, True)
    hi = np.where(rounded > cl_fix_max_value(r_fmt), False, True)
    return np.where(np.logical_and(lo,hi), True, False)


def cl_fix_abs(a, a_fmt : FixFormat,
               r_fmt : FixFormat = None,
               rnd : FixRound = FixRound.Trunc_s, sat : FixSaturate = FixSaturate.None_s):
    """
    Calculates absolute values, abs(a).
    """
    a = _clean_input(a)
    
    # Full-precision result format
    mid_fmt = cl_fix_abs_fmt(a_fmt)
    if r_fmt is None:
        r_fmt = mid_fmt
    
    # Handle narrow/wide internal representation
    a_wide = cl_fix_is_wide(a_fmt)
    mid_wide = cl_fix_is_wide(mid_fmt)
    if a_wide or mid_wide:
        # WideFix
        a = WideFix(a, a_fmt) if a_wide else WideFix.from_narrowfix(a, a_fmt)
    else:
        # NarrowFix
        a = NarrowFix(a, a_fmt, copy=False)
    
    mid = a.abs()
    return cl_fix_resize(mid._data, mid_fmt, r_fmt, rnd, sat)


def cl_fix_neg(a, a_fmt : FixFormat,
              r_fmt : FixFormat = None,
              rnd : FixRound = FixRound.Trunc_s, sat : FixSaturate = FixSaturate.None_s):
    """
    Calculates negation, -a.
    """
    a = _clean_input(a)
    
    # Full-precision result format
    mid_fmt = cl_fix_neg_fmt(a_fmt)
    if r_fmt is None:
        r_fmt = mid_fmt
    
    # Handle narrow/wide internal representation
    a_wide = cl_fix_is_wide(a_fmt)
    mid_wide = cl_fix_is_wide(mid_fmt)
    if a_wide or mid_wide:
        # WideFix
        a = WideFix(a, a_fmt) if a_wide else WideFix.from_narrowfix(a, a_fmt)
    else:
        # NarrowFix
        a = NarrowFix(a, a_fmt, copy=False)
    
    mid = -a
    return cl_fix_resize(mid._data, mid_fmt, r_fmt, rnd, sat)


def cl_fix_add(a, a_fmt : FixFormat,
               b, b_fmt : FixFormat,
               r_fmt : FixFormat = None,
               rnd : FixRound = FixRound.Trunc_s, sat : FixSaturate = FixSaturate.None_s):
    """
    Calculates addition, a + b.
    """
    a = _clean_input(a)
    b = _clean_input(b)
    
    # Full-precision result format
    mid_fmt = cl_fix_add_fmt(a_fmt, b_fmt)
    if r_fmt is None:
        r_fmt = mid_fmt
    
    # Handle narrow/wide internal representation
    a_wide = cl_fix_is_wide(a_fmt)
    b_wide = cl_fix_is_wide(b_fmt)
    mid_wide = cl_fix_is_wide(mid_fmt)
    if a_wide or b_wide or mid_wide:
        # WideFix
        a = WideFix(a, a_fmt) if a_wide else WideFix.from_narrowfix(a, a_fmt)
        b = WideFix(b, b_fmt) if b_wide else WideFix.from_narrowfix(b, b_fmt)
    else:
        # NarrowFix
        a = NarrowFix(a, a_fmt, copy=False)
        b = NarrowFix(b, b_fmt, copy=False)
    
    mid = a+b
    return cl_fix_resize(mid._data, mid_fmt, r_fmt, rnd, sat)


def cl_fix_sub(a, a_fmt : FixFormat,
               b, b_fmt : FixFormat,
               r_fmt : FixFormat = None,
               rnd : FixRound = FixRound.Trunc_s, sat : FixSaturate = FixSaturate.None_s):
    """
    Calculates subtraction, a - b.
    """
    a = _clean_input(a)
    b = _clean_input(b)
    
    # Full-precision result format
    mid_fmt = cl_fix_sub_fmt(a_fmt, b_fmt)
    if r_fmt is None:
        r_fmt = mid_fmt
    
    # Handle narrow/wide internal representation
    a_wide = cl_fix_is_wide(a_fmt)
    b_wide = cl_fix_is_wide(b_fmt)
    mid_wide = cl_fix_is_wide(mid_fmt)
    if a_wide or b_wide or mid_wide:
        # WideFix
        a = WideFix(a, a_fmt) if a_wide else WideFix.from_narrowfix(a, a_fmt)
        b = WideFix(b, b_fmt) if b_wide else WideFix.from_narrowfix(b, b_fmt)
    else:
        # NarrowFix
        a = NarrowFix(a, a_fmt, copy=False)
        b = NarrowFix(b, b_fmt, copy=False)
    
    mid = a-b
    return cl_fix_resize(mid._data, mid_fmt, r_fmt, rnd, sat)


def cl_fix_addsub(a, a_fmt : FixFormat,
                  b, b_fmt : FixFormat,
                  add,  # Bool or bool array.
                  r_fmt : FixFormat = None,
                  rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    """
    Calculates addition/subtraction:
        a + b, where add == True.
        a - b, where add == False.
    """
    radd = cl_fix_add(a, a_fmt, b, b_fmt, r_fmt, rnd, sat)
    rsub = cl_fix_sub(a, a_fmt, b, b_fmt, r_fmt, rnd, sat)
    return np.where(add, radd, rsub)


def cl_fix_mult(a, a_fmt : FixFormat,
                b, b_fmt : FixFormat,
                r_fmt : FixFormat = None,
                rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    """
    Calculates multiplication, a * b.
    """
    a = _clean_input(a)
    b = _clean_input(b)
    
    # Full-precision result format
    mid_fmt = cl_fix_mult_fmt(a_fmt, b_fmt)
    if r_fmt is None:
        r_fmt = mid_fmt
    
    # Handle narrow/wide internal representation
    a_wide = cl_fix_is_wide(a_fmt)
    b_wide = cl_fix_is_wide(b_fmt)
    mid_wide = cl_fix_is_wide(mid_fmt)
    if a_wide or b_wide or mid_wide:
        # WideFix
        a = WideFix(a, a_fmt) if a_wide else WideFix.from_narrowfix(a, a_fmt)
        b = WideFix(b, b_fmt) if b_wide else WideFix.from_narrowfix(b, b_fmt)
    else:
        # NarrowFix
        a = NarrowFix(a, a_fmt, copy=False)
        b = NarrowFix(b, b_fmt, copy=False)
    
    mid = a*b
    return cl_fix_resize(mid._data, mid_fmt, r_fmt, rnd, sat)


def cl_fix_shift(a, a_fmt : FixFormat,
                 shift : int,
                 r_fmt : FixFormat,
                 rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    """
    Calculates a left bit-shift (equivalent to *2.0**shift). To shift right, set shift < 0.
    
    Note: This function performs a lossless shift (equivalent to *2.0**shift), then resizes to the
    output format. The initial shift does NOT truncate any bits.
    """
    a = _clean_input(a)
    
    # Full-precision result format
    mid_fmt = cl_fix_shift_fmt(a_fmt, np.min(shift), np.max(shift))
    if r_fmt is None:
        r_fmt = mid_fmt
    
    # Handle narrow/wide internal representation
    a_wide = cl_fix_is_wide(a_fmt)
    mid_wide = cl_fix_is_wide(mid_fmt)
    if a_wide or mid_wide:
        # WideFix
        a = WideFix(a, a_fmt) if a_wide else WideFix.from_narrowfix(a, a_fmt)
    else:
        # NarrowFix
        a = NarrowFix(a, a_fmt, copy=False)
    
    mid = a << shift
    return cl_fix_resize(mid._data, mid_fmt, r_fmt, rnd, sat)


# Function aliases
cl_fix_add_fmt = FixFormat.ForAdd
cl_fix_sub_fmt = FixFormat.ForSub
cl_fix_addsub_fmt = FixFormat.ForAddsub
cl_fix_mult_fmt = FixFormat.ForMult
cl_fix_neg_fmt = FixFormat.ForNeg
cl_fix_abs_fmt = FixFormat.ForAbs
cl_fix_shift_fmt = FixFormat.ForShift
cl_fix_round_fmt = FixFormat.ForRound
cl_fix_union_fmt = FixFormat.Union

###################################################################################################
# Simulation utility functions (not available in VHDL)
###################################################################################################

def cl_fix_format_to_string(fmt : FixFormat) -> str:
    """
    Converts a FixFormat to string.
    """
    return str(fmt)


def cl_fix_write_formats(fmts, names, filename : str):
    """
    Writes a collection of fixed-point formats to file.
    """
    with open(filename, "w") as fid:
        # Write header
        header = "# " + ",".join(names)
        fid.write(header + "\n")
        
        # Allow input to be a scalar fmt
        if np.ndim(fmts) == 0:
            fmts = np.array(fmts, ndmin=1)
        
        for fmt in fmts:
            fid.write(cl_fix_format_to_string(fmt) + "\n")


def cl_fix_zeros(shape, fmt : FixFormat):
    """
    Generates fixed-point zeros.
    """
    return cl_fix_from_real(np.zeros(shape), fmt)


def cl_fix_random(shape, fmt : FixFormat):
    """
    Generates fixed-point random data, uniformly distributed across the representable range.
    """
    # Generate random data values distributed across the whole dynamic range of fmt.
    fmt_min = cl_fix_min_value(fmt)
    fmt_max = cl_fix_max_value(fmt)
    if cl_fix_is_wide(fmt):
        n = np.prod(shape)
        xint = np.empty((n,), dtype=object)
        for i in range(n):
            xint[i] = random.randrange(fmt_min, fmt_max+1)
        
        return WideFix(xint.reshape(shape), fmt)._data
    else:
        int_min = fmt_min*2**fmt.F
        int_max = fmt_max*2**fmt.F
        xint = np.random.randint(int_min, int_max+1, shape, np.int64)
        return (xint / 2**fmt.F).astype(float)
