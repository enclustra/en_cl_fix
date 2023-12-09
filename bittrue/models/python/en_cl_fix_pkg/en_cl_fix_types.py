###################################################################################################
# Copyright (c) 2023 Enclustra GmbH, Switzerland (info@enclustra.com)
###################################################################################################

###################################################################################################
# Description:
#
# Common types used by en_cl_fix_pkg and wide_fxp class.
###################################################################################################

from enum import Enum
import copy


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
    def ForAdd(aFmt, bFmt):
        """
        Returns the minimal FixFormat that is guaranteed to exactly represent the result of an
        addition, a + b.
        
        This is a conservative calculation (it assumes that a and b may take any values). If the
        values of a and/or b are constrained, then a narrower format may be feasible.
        """
        assert aFmt.width > 0 and bFmt.width > 0, "Data widths must be positive"
        # We must consider both extremes:
        
        # rmax = amax+bmax
        #      = (2**aFmt.I - 2**-aFmt.F) + (2**bFmt.I - 2**-bFmt.F)
        # If aFmt.I >= bFmt.I, then we get 1 bit of growth if:
        #           -2**-aFmt.F + 2**bFmt.I - 2**-bFmt.F >= 0
        # If bFmt.I >= aFmt.I, then we get 1 bit of growth if:
        #           -2**-bFmt.F + 2**aFmt.I - 2**-aFmt.F >= 0
        # Note that the aFmt.I == bFmt.I case is covered by either condition.
        # We define maxFmt as the format with most int bits, and minFmt as the other. (As noted
        # above, it doesn't matter which we treat as max/min when aFmt.I == bFmt.I). This gives a
        # general expression for when bit-growth happens:
        #           -2**-maxFmt.F + 2**minFmt.I - 2**-minFmt.F >= 0
        # If we rearrange the expression into pure integer arithmetic, we get:
        #      2**(minFmt.F+minFmt.I+maxFmt.F) >= 2**minFmt.F + 2**maxFmt.F
        # Equality is only possible if the RHS is a power of 2, so we can remove the 2**n by
        # splitting this into two simple cases:
        #      (1) If minFmt.F == maxFmt.F = F:
        #          F+minFmt.I+F >= F+1
        #          minFmt.I+F >= 1
        #          minFmt.I+F > 0
        #      (2) Else:
        #          minFmt.F+minFmt.I+maxFmt.F > max(minFmt.F, maxFmt.F)
        #          minFmt.I+maxFmt.F > max(minFmt.F, maxFmt.F) - minFmt.F
        # Clearly, the expression for (2) also covers (1). We finally simplify the expression by
        # noting that in general x+y-max(x,y) = min(x,y):
        #          minFmt.I + min(minFmt.F, maxFmt.F) > 0
        #          min(aFmt.I, bFmt.I) + min(aFmt.F, bFmt.F) > 0
        # There is probably a more direct way to derive this simple expression.
        rmax_growth = 1 if min(aFmt.I, bFmt.I) + min(aFmt.F, bFmt.F) > 0 else 0
        
        # rmin = amin+bmin
        #     If aFmt.S = 0 and bFmt.S = 0: 0 + 0
        #     If aFmt.S = 0 and bFmt.S = 1: 0 + -2**bFmt.I
        #     If aFmt.S = 1 and bFmt.S = 0: -2**aFmt.I + 0
        #     If aFmt.S = 1 and bFmt.S = 1: -2**aFmt.I + -2**bFmt.I
        rmin_growth = 1 if aFmt.S == 1 and bFmt.S == 1 else 0
        
        return FixFormat(max(aFmt.S, bFmt.S), max(aFmt.I, bFmt.I) + max(rmin_growth, rmax_growth), max(aFmt.F, bFmt.F))
    
    
    @staticmethod
    def ForSub(aFmt, bFmt):
        """
        Returns the minimal FixFormat that is guaranteed to exactly represent the result of a
        subtraction, a - b.
        
        This is a conservative calculation (it assumes that a and b may take any values). If the
        values of a and/or b are constrained, then a narrower format may be feasible.
        """
        assert aFmt.width > 0 and bFmt.width > 0, "Data widths must be positive"
        # We must consider both extremes:
        
        # rmax = amax-bmin
        #     If bFmt.S = 0: rmax = (2**aFmt.I - 2**-aFmt.F) - 0
        #     If bFmt.S = 1: rmax = (2**aFmt.I - 2**-aFmt.F) + 2**bFmt.I
        # If bFmt.S = 0, then rmaxFmt = aFmt.
        # If bFmt.S = 1 and aFmt.I >= bFmt.I, then we get 1 bit of growth if:
        #                -2**-aFmt.F + 2**bFmt.I >= 0
        #                              2**bFmt.I >= 2**-aFmt.F
        # If bFmt.S = 1 and bFmt.I >= aFmt.I, then we get 1 bit of growth if:
        #                -2**-aFmt.F + 2**aFmt.I >= 0
        #                              2**aFmt.I >= 2**-aFmt.F
        if bFmt.S == 0:
            rmaxI = aFmt.I
        else:
            rmax_growth = bFmt.S if min(aFmt.I, bFmt.I) >= -aFmt.F else 0
            rmaxI = max(aFmt.I, bFmt.I) + rmax_growth
        
        # rmin = amin-bmax
        #     If aFmt.S = 0: rmin = 0 - (2**bFmt.I - 2**-bFmt.F)
        #     If aFmt.S = 1: rmin = -2**aFmt.I - (2**bFmt.I - 2**-bFmt.F)
        # If aFmt.S = 0 and bFmt.I = -bFmt.F, then rFmt.S=0 with no requirement on rFmt.I.
        # If aFmt.S = 0 and bFmt.I = -bFmt.F+1, then we have a special case (power of 2) such that
        # rmin = -2**-bFmt.F, so rFmt.S=1 and rFmt.I = -bFmt.F.
        # If aFmt.S = 0 and (all other cases), then rFmt.S=1 and rFmt.I=bFmt.I.
        # If aFmt.S = 1 and aFmt.I >= bFmt.I, then we get 1 bit of growth if:
        #                       2**bFmt.I - 2**-bFmt.F > 0
        # If aFmt.S = 1 and bFmt.I >= aFmt.I, then we get 1 bit of growth if:
        #                       2**aFmt.I - 2**-bFmt.F > 0
        if aFmt.S == 0:
            if bFmt.width == 1 and bFmt.S == 1:
                # Special case: a is unsigned and b is 1-bit signed:
                S = 0
                I = rmaxI
            elif bFmt.I == -bFmt.F+1:
                # Special case: a is unsigned and rmin is a power of 2
                S = 1
                I = max(rmaxI, -bFmt.F)
            else:
                # Normal case for unsigned a
                S = 1
                I = max(rmaxI, bFmt.I)
        else:
            # Signed a
            S = 1
            rmin_growth = aFmt.S if min(aFmt.I, bFmt.I) > -bFmt.F else 0
            rminI = max(aFmt.I, bFmt.I) + rmin_growth
            I = max(rmaxI, rminI)
        
        return FixFormat(S, I, max(aFmt.F, bFmt.F))
    
    
    @staticmethod
    def ForAddsub(aFmt, bFmt):
        """
        Returns the minimal FixFormat that is guaranteed to exactly represent the result of an
        addition/subtraction, a +/- b.
        
        This is a conservative calculation (it assumes that a and b may take any values). If the
        values of a and/or b are constrained, then a narrower format may be feasible.
        """
        assert aFmt.width > 0 and bFmt.width > 0, "Data widths must be positive"
        addFmt = FixFormat.ForAdd(aFmt, bFmt)
        subFmt = FixFormat.ForSub(aFmt, bFmt)
        return FixFormat.Union(addFmt, subFmt)
    
    
    @staticmethod
    def ForMult(aFmt, bFmt):
        """
        Returns the minimal FixFormat that is guaranteed to exactly represent the result of a
        multiplication, a * b.
        
        This is a conservative calculation (it assumes that a and b may take any values). If the
        values of a and/or b are constrained, then a narrower format may be feasible.
        """
        assert aFmt.width > 0 and bFmt.width > 0, "Data widths must be positive"
        # We must consider both extremes:
        
        # rmax:
        # If aFmt.S == 1 and bFmt.S == 1, then:
        #     rmax = amin * bmin
        #          = -2**aFmt.I * -2**bFmt.I = 2**(aFmt.I + bFmt.I)
        #          ==> aFmt.I + bFmt.I + 1 int bits.
        # Else:
        #     rmax = amax * bmax
        #          = (2**aFmt.I - 2**-aFmt.F) * (2**bFmt.I - 2**-bFmt.F)
        #          = 2**(aFmt.I + bFmt.I) - 2**(aFmt.I - bFmt.F) - 2**(bFmt.I - aFmt.F) + 2**(-aFmt.F - bFmt.F)
        #     This will typically need aFmt.I + bFmt.I int bits, but -1 bit if:
        #          2**(aFmt.I + bFmt.I) - 2**(aFmt.I - bFmt.F) - 2**(bFmt.I - aFmt.F) + 2**(-aFmt.F - bFmt.F) < 2**(aFmt.I + bFmt.I - 1)
        #     If we define x=aFmt.I+aFmt.F and y=bFmt.I+bFmt.F, then we can rearrange this to:
        #          2**(x+y-1) + 1 < 2**x + 2**y
        #     Further rearrangement leads to:
        #          (2**x - 2)(2**y - 2) < 2
        #     Note that x>=0 and y>=0 because we do not support I+F<0. So, it is fairly easy to see
        #     the inequality is true iff x<=1 or y<=1 (and this is trivial to confirm numerically).
        if aFmt.S == 1 and bFmt.S == 1:
            rmaxI = aFmt.I + bFmt.I + 1
        elif aFmt.I+aFmt.F <= 1 or bFmt.I+bFmt.F <= 1:
            rmaxI = aFmt.I + bFmt.I - 1
        else:
            rmaxI = aFmt.I + bFmt.I
        
        # rmin:
        # If aFmt.S == 0 and bFmt.S == 0, then:
        #     rmin = amin * bmin = 0
        #     ==> No requirement.
        # If aFmt.S == 0 and bFmt.S == 1, then:
        #     rmin = amax * bmin = (2**aFmt.I - 2**-aFmt.F) * -2**bFmt.I
        #                        = -amax * 2**bFmt.I
        #     ==> Same as FixFormat.ForNeg(aFmt).I + bFmt.I
        # If aFmt.S == 1 and bFmt.S == 0, then:
        #     rmin = amin * bmax
        #     ==> Same as FixFormat.ForNeg(bFmt).I + aFmt.I
        # If aFmt.S == 1 and bFmt.S == 1, then:
        #     rmin = min(amax * bmin, amin * bmax)
        #     ==> Never exceeds rmaxI ==> Ignore.
        
        # The requirement can exceed rmaxI only if aFmt.S != bFmt.S and we don't run into the same
        # special case as FixFormat.ForNeg() (i.e. the unsigned value being 1-bit).
        if aFmt.S == 0 and bFmt.S == 1:
            I = max(rmaxI, FixFormat.ForNeg(aFmt).I + bFmt.I)
        elif aFmt.S == 1 and bFmt.S == 0:
            I = max(rmaxI, aFmt.I + FixFormat.ForNeg(bFmt).I)
        else:
            I = rmaxI
        
        # Sign bit
        if aFmt.width == 1 and aFmt.S == 1 and bFmt.width == 1 and bFmt.S == 1:
            # Special case: 1-bit signed * 1-bit signed is unsigned
            S = 0
        else:
            # Normal: If either input is signed, then output is signed
            S = max(aFmt.S, bFmt.S)
        
        return FixFormat(S, I, aFmt.F+bFmt.F)
    
    
    @staticmethod
    def ForNeg(aFmt):
        """
        Returns the minimal FixFormat that is guaranteed to exactly represent the result of a
        negation, -a.
        
        This is a conservative calculation (it assumes that a may take any values). If the values
        of a are constrained, then a narrower format may be feasible.
        """
        assert aFmt.width > 0, "Data width must be positive"
        # 1-bit unsigned inputs are special (neg is 1-bit signed)
        if aFmt.S == 0 and aFmt.width == 1:
            return FixFormat(1, aFmt.I+aFmt.S-1, aFmt.F)
        return FixFormat(1, aFmt.I+aFmt.S, aFmt.F)
    
    
    @staticmethod
    def ForAbs(aFmt):
        """
        Returns the minimal FixFormat that is guaranteed to exactly represent the result of an
        absolute value, abs(a).
        
        This is a conservative calculation (it assumes that a may take any values). If the values
        of a are constrained, then a narrower format may be feasible.
        """
        assert aFmt.width > 0, "Data width must be positive"
        negFmt = FixFormat.ForNeg(aFmt)
        return FixFormat.Union(aFmt, negFmt)
    
    
    @staticmethod
    def ForShift(aFmt, minShift, maxShift=None):
        """
        Returns the minimal FixFormat that is guaranteed to exactly represent the result of a
        left shift, a << n.
        
        This is a conservative calculation (it assumes that a may take any values). If the values
        of a are constrained, then a narrower format may be feasible.
        """
        assert aFmt.width > 0, "Data width must be positive"
        if maxShift is None:
            maxShift = minShift
        assert minShift <= maxShift, f"minShift ({minShift}) must be <= maxShift ({maxShift})"
        return FixFormat(aFmt.S, aFmt.I + maxShift, aFmt.F - minShift)
    
    # Format for result of rounding
    @staticmethod
    def ForRound(aFmt, rFracBits : int, rnd : FixRound):
        """
        Returns the minimal FixFormat that is guaranteed to exactly represent the result of
        fixed-point rounding (for a specific rounding mode).
        
        This is a conservative calculation (it assumes that a may take any values). If the values
        of a are constrained, then a narrower format may be feasible.
        """
        assert aFmt.width > 0, "Data width must be positive"
        if rFracBits >= aFmt.F:
            # If fractional bits are not being reduced, then nothing happens to int bits.
            I = aFmt.I
        elif rnd == FixRound.Trunc_s:
            # Crude truncation has no effect on int bits.
            I = aFmt.I
        else:
            # All other rounding modes can overflow into +1 int bit.
            I = aFmt.I + 1
        
        # Force result to be at least 1 bit wide
        if aFmt.S + I + rFracBits < 1:
            I = -aFmt.S - rFracBits + 1
        
        return FixFormat(aFmt.S, I, rFracBits)
    
    
    @staticmethod
    def Union(aFmt, bFmt=None):
        """
        Returns the minimal FixFormat that can exactly represent ALL of the input formats.
        
        Note: The input formats can be either 2 FixFormats, or 1 collection of FixFormats.
        """
        if bFmt is None:
            Fmts = aFmt
        else:
            Fmts = (aFmt, bFmt)
        
        rFmt = copy.copy(Fmts[0])
        for i in range(1, len(Fmts)):
            rFmt.S = max(rFmt.S, Fmts[i].S)
            rFmt.I = max(rFmt.I, Fmts[i].I)
            rFmt.F = max(rFmt.F, Fmts[i].F)
        return rFmt
    
    
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
    
    @property
    def is_wide(self):
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
        is never overflowed, then 54-bit signed numbers and 53-bit unsigned numbers are guaranteed
        to be represented exactly. In theory, this would mean: return fmt.I + fmt.F > 53.
        However, handling wrapping of signed numbers (when saturation is disabled) is made simpler
        if we reserve an extra integer bit for signed numbers. This gives a consistent 53-bit limit
        for both signed and unsigned numbers.
        """
        return self.width > 53
    