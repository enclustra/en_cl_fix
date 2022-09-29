###################################################################################################
# Copyright (c) 2021 Enclustra GmbH, Switzerland (info@enclustra.com)
###################################################################################################

###################################################################################################
# Description:
# Common types used by en_cl_fix_pkg and wide_fxp class.
###################################################################################################

from enum import Enum

class FixFormat:
    def __init__(self, S : int, I : int, F : int):
        assert S == 0 or S == 1, "S must be 0 or 1"
        assert S+I+F >= 0, "Format width cannot be negative"
        self.S = int(S)
        self.I = int(I)
        self.F = int(F)
    
    # Format for result of addition
    @staticmethod
    def ForAdd(aFmt, bFmt):
        return FixFormat(max(aFmt.S, bFmt.S), max(aFmt.I, bFmt.I)+1, max(aFmt.F, bFmt.F))
    
    # Format for result of subtraction
    @staticmethod
    def ForSub(aFmt, bFmt):
        return FixFormat(True, max(aFmt.I, bFmt.I+bFmt.S), max(aFmt.F, bFmt.F))
    
    # Format for result of multiplication
    @staticmethod
    def ForMult(aFmt, bFmt):
        signed = max(aFmt.S, bFmt.S)
        return FixFormat(signed, aFmt.I+bFmt.I+signed, aFmt.F+bFmt.F)
    
    # Format for result of negation
    @staticmethod
    def ForNeg(aFmt):
        return FixFormat(True, aFmt.I+aFmt.S, aFmt.F)
    
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
