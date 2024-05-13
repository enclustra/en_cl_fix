###################################################################################################
# Copyright (c) 2024 Enclustra GmbH, Switzerland (info@enclustra.com)
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software
# and associated documentation files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
# BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
###################################################################################################

###################################################################################################
# Description:
#
# Common types used throughout en_cl_fix.
###################################################################################################

from enum import Enum
from copy import copy as shallow_copy


class FixRound(Enum):
    """
    Fixed-point rounding modes.
    """
    Trunc_s = 0         # Truncation (no rounding).
    NonSymPos_s = 1     # Non-symmetric positive (half-up).
    NonSymNeg_s = 2     # Non-symmetric negative (half-down).
    SymInf_s = 3        # Symmetric towards +/- infinity.
    SymZero_s = 4       # Symmetric towards 0.
    ConvEven_s = 5      # Convergent towards even number.
    ConvOdd_s = 6       # Convergent towards odd number.


class FixSaturate(Enum):
    """
    Fixed-point saturation modes.
    """
    None_s = 0          # No saturation, no warning.
    Warn_s = 1          # No saturation, only warning.
    Sat_s = 2           # Only saturation, no warning.
    SatWarn_s = 3       # Saturation and warning.


class FixFormat:
    """
    Fixed-point number format, [S, I, F], where:
        S = Number of sign bits (0 or 1).
        I = Number of integer bits.
        F = Number of fractional bits.
    """
    
    def __init__(self, S : int, I : int, F : int):
        assert S == 0 or S == 1, "S must be 0 or 1"
        # We allow unsigned null formats such as: (0,0,0) or (0,-5,5).
        # We allow signed sign-bit only such as:  (1,0,0) or (1,-5,5).
        # We do not allow signed null formats such as (1,-1,0) or negative widths such as (0,-1,0)
        # as they create awkward edge cases (e.g. in cl_fix_max_value) and have no practical use.
        assert I+F >= 0, "I+F must be at least 0"
        self.S = int(S)
        self.I = int(I)
        self.F = int(F)
    
    
    @staticmethod
    def for_add(a_fmt, b_fmt):
        """
        Returns the minimal FixFormat that is guaranteed to exactly represent the result of an
        addition, a + b.
        
        This is a conservative calculation (it assumes that a and b may take any values). If the
        values of a and/or b are constrained, then a narrower format may be feasible.
        """
        assert a_fmt.width > 0 and b_fmt.width > 0, "Data widths must be positive"
        # We must consider both extremes:
        
        # rmax = amax+bmax
        #      = (2**a_fmt.I - 2**-a_fmt.F) + (2**b_fmt.I - 2**-b_fmt.F)
        # If a_fmt.I >= b_fmt.I, then we get 1 bit of growth if:
        #           -2**-a_fmt.F + 2**b_fmt.I - 2**-b_fmt.F >= 0
        # If b_fmt.I >= a_fmt.I, then we get 1 bit of growth if:
        #           -2**-b_fmt.F + 2**a_fmt.I - 2**-a_fmt.F >= 0
        # Note that the a_fmt.I == b_fmt.I case is covered by either condition.
        # We define max_fmt as the format with most int bits, and min_fmt as the other. (As noted
        # above, it doesn't matter which we treat as max/min when a_fmt.I == b_fmt.I). This gives a
        # general expression for when bit-growth happens:
        #           -2**-max_fmt.F + 2**min_fmt.I - 2**-min_fmt.F >= 0
        # If we rearrange the expression into pure integer arithmetic, we get:
        #      2**(min_fmt.F+min_fmt.I+max_fmt.F) >= 2**min_fmt.F + 2**max_fmt.F
        # Equality is only possible if the RHS is a power of 2, so we can remove the 2**n by
        # splitting this into two simple cases:
        #      (1) If min_fmt.F == max_fmt.F = F:
        #          F+min_fmt.I+F >= F+1
        #          min_fmt.I+F >= 1
        #          min_fmt.I+F > 0
        #      (2) Else:
        #          min_fmt.F+min_fmt.I+max_fmt.F > max(min_fmt.F, max_fmt.F)
        #          min_fmt.I+max_fmt.F > max(min_fmt.F, max_fmt.F) - min_fmt.F
        # Clearly, the expression for (2) also covers (1). We finally simplify the expression by
        # noting that in general x+y-max(x,y) = min(x,y):
        #          min_fmt.I + min(min_fmt.F, max_fmt.F) > 0
        #          min(a_fmt.I, b_fmt.I) + min(a_fmt.F, b_fmt.F) > 0
        # There is probably a more direct way to derive this simple expression.
        rmax_growth = 1 if min(a_fmt.I, b_fmt.I) + min(a_fmt.F, b_fmt.F) > 0 else 0
        
        # rmin = amin+bmin
        #     If a_fmt.S = 0 and b_fmt.S = 0: 0 + 0
        #     If a_fmt.S = 0 and b_fmt.S = 1: 0 + -2**b_fmt.I
        #     If a_fmt.S = 1 and b_fmt.S = 0: -2**a_fmt.I + 0
        #     If a_fmt.S = 1 and b_fmt.S = 1: -2**a_fmt.I + -2**b_fmt.I
        rmin_growth = 1 if a_fmt.S == 1 and b_fmt.S == 1 else 0
        
        return FixFormat(max(a_fmt.S, b_fmt.S), max(a_fmt.I, b_fmt.I) + max(rmin_growth, rmax_growth), max(a_fmt.F, b_fmt.F))
    
    
    @staticmethod
    def for_sub(a_fmt, b_fmt):
        """
        Returns the minimal FixFormat that is guaranteed to exactly represent the result of a
        subtraction, a - b.
        
        This is a conservative calculation (it assumes that a and b may take any values). If the
        values of a and/or b are constrained, then a narrower format may be feasible.
        """
        assert a_fmt.width > 0 and b_fmt.width > 0, "Data widths must be positive"
        # We must consider both extremes:
        
        # rmax = amax-bmin
        #     If b_fmt.S = 0: rmax = (2**a_fmt.I - 2**-a_fmt.F) - 0
        #     If b_fmt.S = 1: rmax = (2**a_fmt.I - 2**-a_fmt.F) + 2**b_fmt.I
        # If b_fmt.S = 0, then rmax_fmt = a_fmt.
        # If b_fmt.S = 1 and a_fmt.I >= b_fmt.I, then we get 1 bit of growth if:
        #                -2**-a_fmt.F + 2**b_fmt.I >= 0
        #                              2**b_fmt.I >= 2**-a_fmt.F
        # If b_fmt.S = 1 and b_fmt.I >= a_fmt.I, then we get 1 bit of growth if:
        #                -2**-a_fmt.F + 2**a_fmt.I >= 0
        #                              2**a_fmt.I >= 2**-a_fmt.F
        if b_fmt.S == 0:
            rmaxI = a_fmt.I
        else:
            rmax_growth = b_fmt.S if min(a_fmt.I, b_fmt.I) >= -a_fmt.F else 0
            rmaxI = max(a_fmt.I, b_fmt.I) + rmax_growth
        
        # rmin = amin-bmax
        #     If a_fmt.S = 0: rmin = 0 - (2**b_fmt.I - 2**-b_fmt.F)
        #     If a_fmt.S = 1: rmin = -2**a_fmt.I - (2**b_fmt.I - 2**-b_fmt.F)
        # If a_fmt.S = 0 and b_fmt.I = -b_fmt.F, then r_fmt.S=0 with no requirement on r_fmt.I.
        # If a_fmt.S = 0 and b_fmt.I = -b_fmt.F+1, then we have a special case (power of 2) such that
        # rmin = -2**-b_fmt.F, so r_fmt.S=1 and r_fmt.I = -b_fmt.F.
        # If a_fmt.S = 0 and (all other cases), then r_fmt.S=1 and r_fmt.I=b_fmt.I.
        # If a_fmt.S = 1 and a_fmt.I >= b_fmt.I, then we get 1 bit of growth if:
        #                       2**b_fmt.I - 2**-b_fmt.F > 0
        # If a_fmt.S = 1 and b_fmt.I >= a_fmt.I, then we get 1 bit of growth if:
        #                       2**a_fmt.I - 2**-b_fmt.F > 0
        if a_fmt.S == 0:
            if b_fmt.width == 1 and b_fmt.S == 1:
                # Special case: a is unsigned and b is 1-bit signed:
                S = 0
                I = rmaxI
            elif b_fmt.I == -b_fmt.F+1:
                # Special case: a is unsigned and rmin is a power of 2
                S = 1
                I = max(rmaxI, -b_fmt.F)
            else:
                # Normal case for unsigned a
                S = 1
                I = max(rmaxI, b_fmt.I)
        else:
            # Signed a
            S = 1
            rmin_growth = a_fmt.S if min(a_fmt.I, b_fmt.I) > -b_fmt.F else 0
            rminI = max(a_fmt.I, b_fmt.I) + rmin_growth
            I = max(rmaxI, rminI)
        
        return FixFormat(S, I, max(a_fmt.F, b_fmt.F))
    
    
    @staticmethod
    def for_addsub(a_fmt, b_fmt):
        """
        Returns the minimal FixFormat that is guaranteed to exactly represent the result of an
        addition/subtraction, a +/- b.
        
        This is a conservative calculation (it assumes that a and b may take any values). If the
        values of a and/or b are constrained, then a narrower format may be feasible.
        """
        assert a_fmt.width > 0 and b_fmt.width > 0, "Data widths must be positive"
        add_fmt = FixFormat.for_add(a_fmt, b_fmt)
        sub_fmt = FixFormat.for_sub(a_fmt, b_fmt)
        return FixFormat.union(add_fmt, sub_fmt)
    
    
    @staticmethod
    def for_mult(a_fmt, b_fmt):
        """
        Returns the minimal FixFormat that is guaranteed to exactly represent the result of a
        multiplication, a * b.
        
        This is a conservative calculation (it assumes that a and b may take any values). If the
        values of a and/or b are constrained, then a narrower format may be feasible.
        """
        assert a_fmt.width > 0 and b_fmt.width > 0, "Data widths must be positive"
        # We must consider both extremes:
        
        # rmax:
        # If a_fmt.S == 1 and b_fmt.S == 1, then:
        #     rmax = amin * bmin
        #          = -2**a_fmt.I * -2**b_fmt.I = 2**(a_fmt.I + b_fmt.I)
        #          ==> a_fmt.I + b_fmt.I + 1 int bits.
        # Else:
        #     rmax = amax * bmax
        #          = (2**a_fmt.I - 2**-a_fmt.F) * (2**b_fmt.I - 2**-b_fmt.F)
        #          = 2**(a_fmt.I + b_fmt.I) - 2**(a_fmt.I - b_fmt.F) - 2**(b_fmt.I - a_fmt.F) + 2**(-a_fmt.F - b_fmt.F)
        #     This will typically need a_fmt.I + b_fmt.I int bits, but -1 bit if:
        #          2**(a_fmt.I + b_fmt.I) - 2**(a_fmt.I - b_fmt.F) - 2**(b_fmt.I - a_fmt.F) + 2**(-a_fmt.F - b_fmt.F) < 2**(a_fmt.I + b_fmt.I - 1)
        #     If we define x=a_fmt.I+a_fmt.F and y=b_fmt.I+b_fmt.F, then we can rearrange this to:
        #          2**(x+y-1) + 1 < 2**x + 2**y
        #     Further rearrangement leads to:
        #          (2**x - 2)(2**y - 2) < 2
        #     Note that x>=0 and y>=0 because we do not support I+F<0. So, it is fairly easy to see
        #     the inequality is true iff x<=1 or y<=1 (and this is trivial to confirm numerically).
        if a_fmt.S == 1 and b_fmt.S == 1:
            rmaxI = a_fmt.I + b_fmt.I + 1
        elif a_fmt.I+a_fmt.F <= 1 or b_fmt.I+b_fmt.F <= 1:
            rmaxI = a_fmt.I + b_fmt.I - 1
        else:
            rmaxI = a_fmt.I + b_fmt.I
        
        # rmin:
        # If a_fmt.S == 0 and b_fmt.S == 0, then:
        #     rmin = amin * bmin = 0
        #     ==> No requirement.
        # If a_fmt.S == 0 and b_fmt.S == 1, then:
        #     rmin = amax * bmin = (2**a_fmt.I - 2**-a_fmt.F) * -2**b_fmt.I
        #                        = -amax * 2**b_fmt.I
        #     ==> Same as FixFormat.for_neg(a_fmt).I + b_fmt.I
        # If a_fmt.S == 1 and b_fmt.S == 0, then:
        #     rmin = amin * bmax
        #     ==> Same as FixFormat.for_neg(b_fmt).I + a_fmt.I
        # If a_fmt.S == 1 and b_fmt.S == 1, then:
        #     rmin = min(amax * bmin, amin * bmax)
        #     ==> Never exceeds rmaxI ==> Ignore.
        
        # The requirement can exceed rmaxI only if a_fmt.S != b_fmt.S and we don't run into the same
        # special case as FixFormat.for_neg() (i.e. the unsigned value being 1-bit).
        if a_fmt.S == 0 and b_fmt.S == 1:
            I = max(rmaxI, FixFormat.for_neg(a_fmt).I + b_fmt.I)
        elif a_fmt.S == 1 and b_fmt.S == 0:
            I = max(rmaxI, a_fmt.I + FixFormat.for_neg(b_fmt).I)
        else:
            I = rmaxI
        
        # Sign bit
        if a_fmt.width == 1 and a_fmt.S == 1 and b_fmt.width == 1 and b_fmt.S == 1:
            # Special case: 1-bit signed * 1-bit signed is unsigned
            S = 0
        else:
            # Normal: If either input is signed, then output is signed
            S = max(a_fmt.S, b_fmt.S)
        
        return FixFormat(S, I, a_fmt.F+b_fmt.F)
    
    
    @staticmethod
    def for_neg(a_fmt):
        """
        Returns the minimal FixFormat that is guaranteed to exactly represent the result of a
        negation, -a.
        
        This is a conservative calculation (it assumes that a may take any values). If the values
        of a are constrained, then a narrower format may be feasible.
        """
        assert a_fmt.width > 0, "Data width must be positive"
        # 1-bit unsigned inputs are special (neg is 1-bit signed)
        if a_fmt.S == 0 and a_fmt.width == 1:
            return FixFormat(1, a_fmt.I+a_fmt.S-1, a_fmt.F)
        return FixFormat(1, a_fmt.I+a_fmt.S, a_fmt.F)
    
    
    @staticmethod
    def for_abs(a_fmt):
        """
        Returns the minimal FixFormat that is guaranteed to exactly represent the result of an
        absolute value, abs(a).
        
        This is a conservative calculation (it assumes that a may take any values). If the values
        of a are constrained, then a narrower format may be feasible.
        """
        assert a_fmt.width > 0, "Data width must be positive"
        neg_fmt = FixFormat.for_neg(a_fmt)
        return FixFormat.union(a_fmt, neg_fmt)
    
    
    @staticmethod
    def for_shift(a_fmt, minShift, maxShift=None):
        """
        Returns the minimal FixFormat that is guaranteed to exactly represent the result of a
        left shift, a << n.
        
        This is a conservative calculation (it assumes that a may take any values). If the values
        of a are constrained, then a narrower format may be feasible.
        """
        assert a_fmt.width > 0, "Data width must be positive"
        if maxShift is None:
            maxShift = minShift
        assert minShift <= maxShift, f"minShift ({minShift}) must be <= maxShift ({maxShift})"
        return FixFormat(a_fmt.S, a_fmt.I + maxShift, a_fmt.F - minShift)
    
    # Format for result of rounding
    @staticmethod
    def for_round(a_fmt, rFracBits : int, rnd : FixRound):
        """
        Returns the minimal FixFormat that is guaranteed to exactly represent the result of
        fixed-point rounding (for a specific rounding mode).
        
        This is a conservative calculation (it assumes that a may take any values). If the values
        of a are constrained, then a narrower format may be feasible.
        """
        assert a_fmt.width > 0, "Data width must be positive"
        if rFracBits >= a_fmt.F:
            # If fractional bits are not being reduced, then nothing happens to int bits.
            I = a_fmt.I
        elif rnd == FixRound.Trunc_s:
            # Crude truncation has no effect on int bits.
            I = a_fmt.I
        else:
            # All other rounding modes can overflow into +1 int bit.
            I = a_fmt.I + 1
        
        # Force result to be at least 1 bit wide
        if a_fmt.S + I + rFracBits < 1:
            I = -a_fmt.S - rFracBits + 1
        
        return FixFormat(a_fmt.S, I, rFracBits)
    
    
    @staticmethod
    def union(a_fmt, b_fmt=None):
        """
        Returns the minimal FixFormat that can exactly represent ALL of the input formats.
        
        Note: The input formats can be either 2 FixFormats, or 1 collection of FixFormats.
        """
        if b_fmt is None:
            fmts = a_fmt
        else:
            fmts = (a_fmt, b_fmt)
        
        r_fmt = shallow_copy(fmts[0])
        for i in range(1, len(fmts)):
            r_fmt.S = max(r_fmt.S, fmts[i].S)
            r_fmt.I = max(r_fmt.I, fmts[i].I)
            r_fmt.F = max(r_fmt.F, fmts[i].F)
        return r_fmt
    
    
    def __repr__(self):
        return "FixFormat" + f"({self.S}, {self.I}, {self.F})"


    def __str__(self):
        return f"({self.S}, {self.I}, {self.F})"


    def __eq__(self, other):
        return (self.S == other.S) and (self.I == other.I) and (self.F == other.F)
    
    
    @property
    def width(self):
        """
        Returns the total bit-width of the FixFormat: S + I + F.
        """
        return self.S + self.I + self.F
    