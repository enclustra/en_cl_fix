###################################################################################################
# Copyright (c) 2021 Enclustra GmbH, Switzerland (info@enclustra.com)
###################################################################################################

###################################################################################################
# Description:
# Common types used by en_cl_fix_pkg and wide_fxp class.
###################################################################################################

from enum import Enum
import warnings

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

class FixFormat:
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
    
    # Format for result of addition
    @staticmethod
    def ForAdd(aFmt, bFmt):
        assert aFmt.width() > 0 and bFmt.width() > 0, "Data widths must be positive"
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
    
    # Format for result of subtraction
    @staticmethod
    def ForSub(aFmt, bFmt):
        assert aFmt.width() > 0 and bFmt.width() > 0, "Data widths must be positive"
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
            if bFmt.width() == 1 and bFmt.S == 1:
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
    
    # Format for result of add-subtract
    @staticmethod
    def ForAddsub(aFmt, bFmt):
        assert aFmt.width() > 0 and bFmt.width() > 0, "Data widths must be positive"
        addFmt = FixFormat.ForAdd(aFmt, bFmt)
        subFmt = FixFormat.ForSub(aFmt, bFmt)
        return FixFormat(max(addFmt.S, subFmt.S), max(addFmt.I, subFmt.I), max(addFmt.F, subFmt.F))
    
    # Format for result of multiplication
    @staticmethod
    def ForMult(aFmt, bFmt):
        assert aFmt.width() > 0 and bFmt.width() > 0, "Data widths must be positive"
        # We get 1 bit of growth for signed*signed (rmax = -2**aFmt.I * -2**bFmt.I).
        growth = min(aFmt.S, bFmt.S)
        signed = max(aFmt.S, bFmt.S)
        return FixFormat(signed, aFmt.I+bFmt.I+growth, aFmt.F+bFmt.F)
    
    # Format for result of negation
    @staticmethod
    def ForNeg(aFmt):
        assert aFmt.width() > 0, "Data width must be positive"
        # 1-bit unsigned inputs are special (neg is 1-bit signed)
        if aFmt.S == 0 and aFmt.width() == 1:
            return FixFormat(1, aFmt.I+aFmt.S-1, aFmt.F)
        return FixFormat(1, aFmt.I+aFmt.S, aFmt.F)
    
    # Format for result of absolute value
    @staticmethod
    def ForAbs(aFmt):
        assert aFmt.width() > 0, "Data width must be positive"
        negFmt = FixFormat.ForNeg(aFmt)
        return FixFormat(max(aFmt.S, negFmt.S), max(aFmt.I, negFmt.I), max(aFmt.F, negFmt.F))
    
    # Format for result of left-shift
    @staticmethod
    def ForShift(aFmt, minShift, maxShift=None):
        assert aFmt.width() > 0, "Data width must be positive"
        if maxShift is None:
            maxShift = minShift
        assert minShift <= maxShift, f"minShift ({minShift}) must be <= maxShift ({maxShift})"
        return FixFormat(aFmt.S, aFmt.I + maxShift, aFmt.F - minShift)
    
    # Format for result of rounding
    @staticmethod
    def ForRound(aFmt, rFracBits : int, rnd : FixRound):
        assert aFmt.width() > 0, "Data width must be positive"
        if rFracBits >= aFmt.F:
            # If fractional bits are not being reduced, then nothing happens to int bits.
            bitGrowth = 0
        elif rnd == FixRound.Trunc_s:
            # Crude truncation has no effect on int bits.
            bitGrowth = 0
        else:
            # All other rounding modes can overflow into +1 int bit.
            bitGrowth = 1
        
        return FixFormat(aFmt.S, aFmt.I + bitGrowth, rFracBits)
    
    def __repr__(self):
        return "FixFormat" + f"({self.S}, {self.I}, {self.F})"

    def __str__(self):
        return f"({self.S}, {self.I}, {self.F})"

    def __eq__(self, other):
        return (self.S == other.S) and (self.I == other.I) and (self.F == other.F)
    
    def width(self):
        return self.S + self.I + self.F
