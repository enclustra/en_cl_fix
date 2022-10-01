###################################################################################################
# Copyright (c) 2021 Enclustra GmbH, Switzerland (info@enclustra.com)
###################################################################################################

###################################################################################################
# Description:
# Common types used by en_cl_fix_pkg and wide_fxp class.
###################################################################################################

from enum import Enum
import warnings

class FixFormat:
    def __init__(self, S : int, I : int, F : int):
        assert S == 0 or S == 1, "S must be 0 or 1"
        if S+I+F < 0:
            Inew = -(S+F)
            warnings.warn(f"Format width cannot be negative. Changing ({S}, {I}, {F}) to ({S}, {Inew}, {F})", Warning)
            I = Inew
        self.S = int(S)
        self.I = int(I)
        self.F = int(F)
    
    # Format for result of addition
    @staticmethod
    def ForAdd(aFmt, bFmt):
        # We must consider both extremes:
        
        # rmax = amax+bmax
        #      = (2**aFmt.I - 2**-aFmt.F) + (2**bFmt.I - 2**-bFmt.F)
        # If we denote the format with max(aFmt.I, bFmt.I) int bits as "maxFmt" and the other
        # format as "minFmt", then we get 1 bit of growth if 2**minFmt.I > 2**-maxFmt.F.
        if aFmt.I >= bFmt.I:
            rmax_growth = 1 if bFmt.I > -aFmt.F else 0
        else:
            rmax_growth = 1 if aFmt.I > -bFmt.F else 0
        
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
        # We must consider both extremes:
        
        # rmax = amax-bmin
        #     If bFmt.S = 0: rmax = (2**aFmt.I - 2**-aFmt.F) - 0
        #     If bFmt.S = 1: rmax = (2**aFmt.I - 2**-aFmt.F) + 2**bFmt.I
        # We get 1 bit of growth in the signed case if -2**-aFmt.F + 2**bFmt.I >= 0.
        rmax_growth = bFmt.S if bFmt.I >= -aFmt.F else 0
        
        # rmin = amin-bmax
        #     If aFmt.S = 0: rmin = 0 - (2**bFmt.I - 2**-bFmt.F)
        #     If aFmt.S = 1: rmin = -2**aFmt.I - (2**bFmt.I - 2**-bFmt.F)
        # We get 1 bit of growth in the signed case if -2**aFmt.I + 2**-bFmt.F < 0.
        rmin_growth = aFmt.S if aFmt.I > -bFmt.F else 0
        
        return FixFormat(1, max(aFmt.I, bFmt.I) + max(rmin_growth, rmax_growth), max(aFmt.F, bFmt.F))
    
    # Format for result of add-subtract
    @staticmethod
    def ForAddsub(aFmt, bFmt):
        addFmt = FixFormat.ForAdd(aFmt, bFmt)
        subFmt = FixFormat.ForSub(aFmt, bFmt)
        return FixFormat(max(addFmt.S, subFmt.S), max(addFmt.I, subFmt.I), max(addFmt.F, subFmt.F))
    
    # Format for result of multiplication
    @staticmethod
    def ForMult(aFmt, bFmt):
        # We get 1 bit of growth for signed*signed (rmax = -2**aFmt.I * -2**bFmt.I).
        growth = min(aFmt.S, bFmt.S)
        signed = max(aFmt.S, bFmt.S)
        return FixFormat(signed, aFmt.I+bFmt.I+growth, aFmt.F+bFmt.F)
    
    # Format for result of negation
    @staticmethod
    def ForNeg(aFmt):
        return FixFormat(1, aFmt.I+aFmt.S, aFmt.F)
    
    # Format for result of absolute value
    @staticmethod
    def ForAbs(aFmt):
        negFmt = FixFormat.ForNeg(aFmt)
        return FixFormat(max(aFmt.S, negFmt.S), max(aFmt.I, negFmt.I), max(aFmt.F, negFmt.F))
    
    # Format for result of left-shift
    @staticmethod
    def ForShift(aFmt, minShift, maxShift=None):
        if maxShift is None:
            maxShift = minShift
        assert minShift <= maxShift, f"minShift ({minShift}) must be <= maxShift ({maxShift})"
        return FixFormat(aFmt.S, aFmt.I + maxShift, aFmt.F - minShift)
    
    def __repr__(self):
        return "FixFormat" + f"({self.S}, {self.I}, {self.F})"

    def __str__(self):
        return f"({self.S}, {self.I}, {self.F})"

    def __eq__(self, other):
        return (self.S == other.S) and (self.I == other.I) and (self.F == other.F)
    
    def width(self):
        return self.S + self.I + self.F

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
