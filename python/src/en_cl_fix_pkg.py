########################################################################################################################
#  Copyright (c) 2018 by Paul Scherrer Institute, Switzerland
#  All rights reserved.
#  Authors: Oliver Bruendler
########################################################################################################################

########################################################################################################################
# Imports
########################################################################################################################
from enum import Enum
import numpy as np

########################################################################################################################
# Helper Classes
########################################################################################################################
class FixFormat:
    def __init__(self, Signed : bool, IntBits : int, FracBits : int):
        self.Signed = Signed
        self.IntBits = IntBits
        self.FracBits = FracBits

    def __str__(self):
        return "({}, {}, {})".format(self.Signed, self.IntBits, self.FracBits)

    def __eq__(self, other):
        return (self.Signed == other.Signed) and (self.IntBits == other.IntBits) and (self.FracBits == other.FracBits)

class FixRound(Enum):
    Trunc_s = 0
    NonSymPos_s = 1
    NonSymNeg_s = 2
    SymInf_s = 3
    SymZero_s = 4
    ConvEven_s = 5
    ConvOdd_s = 6

class FixSaturate(Enum):
    None_s = 0
    Warn_s = 1
    Sat_s = 2
    SatWarn_s = 3


########################################################################################################################
# Bittrue available in VHDL
########################################################################################################################
def cl_fix_width(fmt : FixFormat) -> int:
    return int(fmt.Signed)+fmt.IntBits+fmt.FracBits

def cl_fix_string_from_format(fmt : FixFormat) -> str:
    return str(fmt)

def cl_fix_max_value(rFmt : FixFormat):
    return 2.0**rFmt.IntBits-2.0**(-rFmt.FracBits)

def cl_fix_min_value(rFmt : FixFormat):
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
    return np.floor(a)

def cl_fix_frac(a, aFmt : FixFormat):
    return a % 1

def cl_fix_combine(sign : int, intbits : int, fracbits : int, rFmt : FixFormat):
    return -sign*2.0**rFmt.IntBits + intbits + fracbits*2.0**-rFmt.FracBits

def cl_fix_get_msb(a, aFmt : FixFormat, index : int):
    if aFmt.Signed:
        if index == 0:
            return int(a < 0)
        else:
            return int((a * 2.0 ** (index - aFmt.IntBits - 1)) % 1 >= 0.5)
    else:
        return int((a * 2.0 ** (index - aFmt.IntBits)) % 1 >= 0.5)
def cl_fix_get_lsb(a, aFmt : FixFormat, index : int):
    return cl_fix_get_msb(a, aFmt, cl_fix_width(aFmt)-1-index)

def cl_fix_set_msb(a, aFmt : FixFormat, index : int, value):
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

def cl_fix_from_real(   a,
                        rFmt : FixFormat,
                        saturate : FixSaturate = FixSaturate.SatWarn_s):
    x = np.floor(a*(2.0**rFmt.FracBits)+0.5)/2.0**rFmt.FracBits
    if np.ndim(a) == 0:
        a = np.array(a, ndmin=1)
    if (saturate == FixSaturate.SatWarn_s) or (saturate == FixSaturate.Warn_s):
        if np.max(a) > cl_fix_max_value(rFmt):
            raise ValueError("cl_fix_from_real: Number {} could not be represented by format {}".format(max(a), rFmt))
        if np.min(a) < cl_fix_min_value(rFmt):
            raise ValueError("cl_fix_from_real: Number {} could not be represented by format {}".format(min(a), rFmt))
    if (saturate == FixSaturate.Sat_s) or (saturate == FixSaturate.SatWarn_s):
        x = np.where(x > cl_fix_max_value(rFmt), cl_fix_max_value(rFmt), x)
        x = np.where(x < cl_fix_min_value(rFmt), cl_fix_min_value(rFmt), x)
    return x

def cl_fix_from_bits_as_int(a : int, aFmt : FixFormat):
    value = np.array(a/2**aFmt.FracBits, np.float64)
    if not np.all(cl_fix_in_range(value, aFmt, aFmt)):
        raise ValueError("cl_fix_from_bits_as_int: Value not in number format range")
    return value

def cl_fix_get_bits_as_int(a, aFmt : FixFormat):
    return np.array(np.round(a*2.0**aFmt.FracBits),int)

def cl_fix_resize(  a, aFmt : FixFormat,
                    rFmt : FixFormat,
                    rnd : FixRound = FixRound.Trunc_s, sat : FixSaturate = FixSaturate.None_s):
    #Rounding
    if rFmt.FracBits < aFmt.FracBits:
        if rnd is FixRound.Trunc_s:
            pass
        elif rnd is FixRound.NonSymPos_s:
            a = a + 2.0 ** (-rFmt.FracBits - 1)
        elif rnd is FixRound.NonSymNeg_s:
            a = a + 2.0 ** (-rFmt.FracBits - 1) - 2.0 ** -aFmt.FracBits
        elif rnd is FixRound.SymInf_s:
            a = a + 2.0 ** (-rFmt.FracBits - 1) - 2.0 ** -aFmt.FracBits * int(a < 0)
        elif rnd is FixRound.SymZero_s:
            a = a + 2.0 ** (-rFmt.FracBits - 1) - 2.0 ** -aFmt.FracBits * int(a >= 0)
        elif rnd is FixRound.ConvEven_s:
            a = a + 2.0 ** (-rFmt.FracBits - 1) - 2.0 ** -aFmt.FracBits * ((np.floor(a * 2 ** rFmt.FracBits) + 1) % 2)
        elif rnd is FixRound.ConvOdd_s:
            a = a + 2.0 ** (-rFmt.FracBits - 1) - 2.0 ** -aFmt.FracBits * ((np.floor(a * 2 ** rFmt.FracBits)) % 2)
        else:
            raise Exception("cl_fix_resize : Illegal value for round!")
    result = np.floor(a * 2.0 ** rFmt.FracBits) * 2.0 ** -rFmt.FracBits

    #Saturation warning
    if sat == FixSaturate.Warn_s or sat == FixSaturate.SatWarn_s:
        if rFmt.Signed:
            if np.any(result >= 2.0 ** rFmt.IntBits) or np.any(result < -2.0 ** rFmt.IntBits):
                raise Exception("cl_fix_resize : Saturation warning!")
        else:
            if np.any(result >= 2 ** rFmt.IntBits) or np.any(result < 0):
                raise Exception("cl_fix_resize : Saturation warning!")

    #Saturation
    if sat == FixSaturate.None_s or sat == FixSaturate.Warn_s:
        if rFmt.Signed:
            result = ((result + 2.0 ** rFmt.IntBits) % (2.0 ** (rFmt.IntBits + 1))) - 2.0 ** rFmt.IntBits
        else:
            result = result % (2.0**rFmt.IntBits)
    else:
        result = np.where(result > cl_fix_max_value(rFmt), cl_fix_max_value(rFmt), result)
        result = np.where(result < cl_fix_min_value(rFmt), cl_fix_min_value(rFmt), result)

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
    fullFmt = FixFormat(True, aFmt.IntBits+int(aFmt.Signed), aFmt.FracBits)
    fullA = cl_fix_resize(a, aFmt, fullFmt)
    neg = np.where(fullA < 0, -fullA, fullA)
    return cl_fix_resize(neg, fullFmt, rFmt, rnd, sat)

def cl_fix_sabs(a, aFmt : FixFormat,
                rFmt : FixFormat,
                rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    return cl_fix_sneg(a, aFmt, a < 0, rFmt, rnd, sat)

def cl_fix_neg(a, aFmt : FixFormat,
              rFmt : FixFormat,
              rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    fullFmt = FixFormat(True, aFmt.IntBits+int(aFmt.Signed), aFmt.FracBits)
    fullA = cl_fix_resize(a, aFmt, fullFmt)
    neg = -fullA
    return cl_fix_resize(neg, fullFmt, rFmt, rnd, sat)

def cl_fix_sneg(a, aFmt : FixFormat,
                enable : bool,
                rFmt : FixFormat,
                rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    temp_fmt = FixFormat(True, aFmt.IntBits, max(aFmt.FracBits, rFmt.FracBits))
    temp = cl_fix_resize(a, aFmt, temp_fmt, FixRound.Trunc_s, FixSaturate.None_s)
    temp = -(int(enable))*2 ** -temp_fmt.FracBits + (-1.0) ** int(enable)*temp
    return cl_fix_resize(temp, temp_fmt, rFmt, rnd, sat)



def cl_fix_add( a, aFmt : FixFormat,
                b, bFmt : FixFormat,
                rFmt : FixFormat,
                rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    fullFmt = FixFormat(aFmt.Signed or bFmt.Signed, max(aFmt.IntBits, bFmt.IntBits)+1, max(aFmt.FracBits, bFmt.FracBits))
    fullA = cl_fix_resize(a, aFmt, fullFmt)
    fullB = cl_fix_resize(b, bFmt, fullFmt)
    return cl_fix_resize(fullA+fullB, fullFmt, rFmt, rnd, sat)

def cl_fix_sub( a, aFmt : FixFormat,
                b, bFmt : FixFormat,
                rFmt : FixFormat,
                rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    fullFmt = FixFormat(True, max(aFmt.IntBits, bFmt.IntBits+int(bFmt.Signed)), max(aFmt.FracBits, bFmt.FracBits))
    fullA = cl_fix_resize(a, aFmt, fullFmt)
    fullB = cl_fix_resize(b, bFmt, fullFmt)
    return cl_fix_resize(fullA-fullB, fullFmt, rFmt, rnd, sat)

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
    temp_fmt = FixFormat(aFmt.Signed or bFmt.Signed, max(aFmt.IntBits, bFmt.IntBits) + 1, max(aFmt.FracBits, bFmt.FracBits))
    notAdd = np.array(np.logical_not(add),dtype="int32")
    temp = a + (-1.0) ** notAdd * b - notAdd * 2.0 ** -temp_fmt.FracBits
    return cl_fix_resize(temp, temp_fmt, rFmt, rnd, sat)

def cl_fix_mean(a, aFmt : FixFormat,
                b, bFmt : FixFormat,
                rFmt : FixFormat,
                rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    temp_fmt = FixFormat(aFmt.Signed or bFmt.Signed, max (aFmt.IntBits, bFmt.IntBits)+1, max (aFmt.FracBits, bFmt.FracBits))
    temp = cl_fix_add (a, aFmt, b, bFmt, temp_fmt, FixRound.Trunc_s, FixSaturate.None_s)
    return cl_fix_shift (temp, temp_fmt, -1, rFmt, rnd, sat)

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
    temp_fmt = FixFormat(aFmt.Signed, aFmt.IntBits + shift, aFmt.FracBits - shift)
    return cl_fix_resize(a * 2.0 ** shift, temp_fmt, rFmt, rnd, sat)

def cl_fix_mult(    a, aFmt : FixFormat,
                    b, bFmt : FixFormat,
                    rFmt : FixFormat,
                    rnd: FixRound = FixRound.Trunc_s, sat: FixSaturate = FixSaturate.None_s):
    fullFmt = FixFormat(True, aFmt.IntBits+bFmt.IntBits+1, aFmt.FracBits+bFmt.FracBits)
    return cl_fix_resize(a * b, fullFmt, rFmt, rnd, sat)




########################################################################################################################
# Python only (helpers)
########################################################################################################################
# Currently none






