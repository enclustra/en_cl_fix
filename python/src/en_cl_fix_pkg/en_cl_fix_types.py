###################################################################################################
# Copyright (c) 2021 Enclustra GmbH, Switzerland (info@enclustra.com)
###################################################################################################

###################################################################################################
# Description:
# Common types used by en_cl_fix_pkg and wide_fxp class.
###################################################################################################

from enum import Enum

class FixFormat:
    def __init__(self, Signed : bool, IntBits : int, FracBits : int):
        self.Signed = bool(Signed)
        self.IntBits = int(IntBits)
        self.FracBits = int(FracBits)
    
    # Format for result of addition
    @staticmethod
    def ForAdd(aFmt, bFmt):
        return FixFormat(aFmt.Signed or bFmt.Signed, max(aFmt.IntBits, bFmt.IntBits)+1, max(aFmt.FracBits, bFmt.FracBits))
    
    # Format for result of subtraction
    @staticmethod
    def ForSub(aFmt, bFmt):
        return FixFormat(True, max(aFmt.IntBits, bFmt.IntBits+int(bFmt.Signed)), max(aFmt.FracBits, bFmt.FracBits))
    
    # Format for result of multiplication
    @staticmethod
    def ForMult(aFmt, bFmt):
        return FixFormat(True, aFmt.IntBits+bFmt.IntBits+1, aFmt.FracBits+bFmt.FracBits)
    
    # Format for result of negation
    @staticmethod
    def ForNeg(aFmt):
        return FixFormat(True, aFmt.IntBits+int(aFmt.Signed), aFmt.FracBits)
    
    # Format for result of left-shift
    @staticmethod
    def ForShift(aFmt, shift):
        return FixFormat(aFmt.Signed, aFmt.IntBits + shift, aFmt.FracBits - shift)
    
    def __repr__(self):
        return "FixFormat" + f"({self.Signed}, {self.IntBits}, {self.FracBits})"

    def __str__(self):
        return f"({self.Signed}, {self.IntBits}, {self.FracBits})"

    def __eq__(self, other):
        return (self.Signed == other.Signed) and (self.IntBits == other.IntBits) and (self.FracBits == other.FracBits)
    
    def width(self):
        return int(self.Signed) + self.IntBits + self.FracBits

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
