########################################################################################################################
#  Copyright (c) 2018 by Paul Scherrer Institute, Switzerland
#  All rights reserved.
#  Authors: Oliver Bruendler
########################################################################################################################
import sys
sys.path.append("../src")
from en_cl_fix_pkg import *

import unittest

########################################################################################################################
# Test Cases
########################################################################################################################

### cl_fix_width ###
class cl_fix_width_Test(unittest.TestCase):

    def test_IntOnly_Unsiged_NoFractionalBits(self):
        self.assertEqual(3, cl_fix_width(FixFormat(False, 3, 0)))

    def test_IntOnly_Signed_NoFractionalBits(self):
        self.assertEqual(4, cl_fix_width(FixFormat(True, 3, 0)))

    def test_FractionalOnly_Unsigned_NoIntegerBits(self):
        self.assertEqual(3, cl_fix_width(FixFormat(False, 0, 3)))

    def test_FractionalOnly_Signed_NoIntegerBits(self):
        self.assertEqual(4, cl_fix_width(FixFormat(True, 0, 3)))#

    def test_IntAndFract(self):
        self.assertEqual(7, cl_fix_width(FixFormat(True, 3, 3)))

    def test_NegativeInt(self):
        self.assertEqual(2, cl_fix_width(FixFormat(True, -2, 3)))

    def test_NegativeFract(self):
        self.assertEqual(2, cl_fix_width(FixFormat(True, 3, -2)))

### cl_fix_from_real ###
class cl_fix_from_real_Test(unittest.TestCase):

    def test_Rounding(self):
        self.assertEqual(1.25, cl_fix_from_real(1.2, FixFormat(False, 2, 2)))
        self.assertEqual(-0.5, cl_fix_from_real(-0.52, FixFormat(True, 2, 2)))

    def test_OutOfRangeError(self):
        with self.assertRaises(ValueError):
            cl_fix_from_real(4.2, FixFormat(False, 2, 2))
        with self.assertRaises(ValueError):
            cl_fix_from_real(-0.5, FixFormat(False, 2, 2))
        with self.assertRaises(ValueError):
            cl_fix_from_real(-4.2, FixFormat(True, 2, 2))

    def test_OutOfRangeNoError(self):
        self.assertEqual(3.75, cl_fix_from_real(4.2, FixFormat(False, 2, 2), FixSaturate.Sat_s))
        self.assertEqual(0.0, cl_fix_from_real(-0.5, FixFormat(False, 2, 2), FixSaturate.Sat_s))
        self.assertEqual(-4.0, cl_fix_from_real(-4.2, FixFormat(True, 2, 2), FixSaturate.Sat_s))

    def test_LimitDueToRounding(self):
        with self.assertRaises(ValueError):
            cl_fix_from_real(3.9, FixFormat(False, 2, 2))

### cl_fix_from_bits_as_int ###
class cl_fix_from_bits_as_int_Test(unittest.TestCase):

    def test_Unsigned_Positive(self):
        self.assertEqual(1.5, cl_fix_from_bits_as_int(3, FixFormat(False,3,1)))

    def test_Signed_Positive(self):
        self.assertEqual(1.5, cl_fix_from_bits_as_int(3, FixFormat(True, 2, 1)))

    def test_Signed_Negative(self):
        self.assertEqual(-1.5, cl_fix_from_bits_as_int(-3, FixFormat(True, 2, 1)))

    def test_Wrap_Unsigned(self):
        with self.assertRaises(ValueError):
            self.assertEqual(1, cl_fix_from_bits_as_int(17, FixFormat(False, 4, 0)))

### cl_fix_get_bits_as_int ###
class cl_fix_get_bits_as_int_Test(unittest.TestCase):

    def test_Unsigned_Positive(self):
        self.assertEqual(3, cl_fix_get_bits_as_int(1.5, FixFormat(False, 3, 1)), FixFormat(False, 3, 1))

    def test_Signed_Positive(self):
        self.assertEqual(3, cl_fix_get_bits_as_int(1.5, FixFormat(True, 2, 1)), FixFormat(True, 2, 1))

    def test_Signed_Negative(self):
        self.assertEqual(-3, cl_fix_get_bits_as_int(-1.5, FixFormat(True, 2, 1)), FixFormat(True, 2, 1))

### cl_fix_resize ###
class cl_fix_resize_Test(unittest.TestCase):

    def test_NoFormatChange(self):
        self.assertEqual(2.5, cl_fix_resize(2.5, FixFormat(True,2,1), FixFormat(True,2,1)))

    def test_RemoveFracBit1_Trunc(self):
        self.assertEqual(2.0, cl_fix_resize(2.5, FixFormat(True,2,1), FixFormat(True,2,0), FixRound.Trunc_s))

    def test_RemoveFracBit1_Round(self):
        self.assertEqual(3.0, cl_fix_resize(2.5, FixFormat(True, 2, 1), FixFormat(True, 2, 0), FixRound.NonSymPos_s))

    def test_RemoveFracBit0_Trunc(self):
        self.assertEqual(2.0, cl_fix_resize(2.0, FixFormat(True,2,1), FixFormat(True,2,0), FixRound.Trunc_s))

    def test_RemoveFracBit0_Round(self):
        self.assertEqual(2.0, cl_fix_resize(2.0, FixFormat(True,2,1), FixFormat(True,2,0), FixRound.NonSymPos_s))

    def test_AddFracBit_Signed(self):
       self.assertEqual(2.0, cl_fix_resize(2.0, FixFormat(True,2,1), FixFormat(True,2,2), FixRound.NonSymPos_s))

    def test_AddFracBit_Unsigned(self):
        self.assertEqual(2.0, cl_fix_resize(2.0, FixFormat(False,2,1), FixFormat(False,2,2), FixRound.NonSymPos_s))

    def test_RemoveInterBit_Signed_NoSat_Positive(self):
        self.assertEqual(3.5, cl_fix_resize(3.5, FixFormat(True,3,1), FixFormat(True,2,1), FixRound.Trunc_s, FixSaturate.None_s))

    def test_RemoveInterBit_Signed_NoSat_Negative(self):
        self.assertEqual(-3.5, cl_fix_resize(-3.5, FixFormat(True,3,1), FixFormat(True,2,1), FixRound.Trunc_s, FixSaturate.Sat_s))

    def test_RemoveInterBit_Signed_Wrap_Positive(self):
        self.assertEqual(-2.5, cl_fix_resize(5.5, FixFormat(True,3,1), FixFormat(True,2,1), FixRound.Trunc_s, FixSaturate.None_s))

    def test_RemoveInterBit_Signed_Wrap_Negative(self):
        self.assertEqual(1.5, cl_fix_resize(-6.5, FixFormat(True,3,1), FixFormat(True,2,1), FixRound.Trunc_s, FixSaturate.None_s))

    def test_RemoveInterBit_Signed_Sat_Positive(self):
        self.assertEqual(3.5, cl_fix_resize(5.5, FixFormat(True,3,1), FixFormat(True,2,1), FixRound.Trunc_s, FixSaturate.Sat_s))

    def test_RemoveInterBit_Signed_Sat_Negative(self):
        self.assertEqual(-4.0, cl_fix_resize(-6.5, FixFormat(True,3,1), FixFormat(True,2,1), FixRound.Trunc_s, FixSaturate.Sat_s))

    def test_RemoveInterBit_Unsigned_NoSat_Positive(self):
        self.assertEqual(2.5, cl_fix_resize(2.5, FixFormat(False,3,1), FixFormat(False,2,1), FixRound.Trunc_s, FixSaturate.None_s))

    def test_RemoveInterBit_Unsigned_Wrap_Positive(self):
        self.assertEqual(1.5, cl_fix_resize(5.5, FixFormat(False,3,1), FixFormat(False,2,1), FixRound.Trunc_s, FixSaturate.None_s))

    def test_RemoveInterBit_Unsigned_Sat_Positive(self):
        self.assertEqual(3.5, cl_fix_resize(5.5, FixFormat(False,3,1), FixFormat(False,2,1), FixRound.Trunc_s, FixSaturate.Sat_s))

    def test_RemoveSignBit_Signed_NoSat_Positive(self):
        self.assertEqual(3.5, cl_fix_resize(3.5, FixFormat(True,3,1), FixFormat(False,3,1), FixRound.Trunc_s, FixSaturate.None_s))

    def test_RemoveSignBit_Signed_Wrap_Negative(self):
        self.assertEqual(1.5, cl_fix_resize(-6.5, FixFormat(True,3,1), FixFormat(False,3,1), FixRound.Trunc_s, FixSaturate.None_s))

    def test_RemoveSignBit_Signed_Sat_Negative(self):
        self.assertEqual(0.0, cl_fix_resize(-6.5, FixFormat(True,3,1), FixFormat(False,3,1), FixRound.Trunc_s, FixSaturate.Sat_s))

    def test_OverflowDueRounding_Signed_Wrap(self):
        self.assertEqual(-8.0, cl_fix_resize(7.5, FixFormat(True,3,1), FixFormat(True,3,0), FixRound.NonSymPos_s, FixSaturate.None_s))

    def test_OverflowDueRounding_Signed_Sat(self):
        self.assertEqual(7.0, cl_fix_resize(7.5, FixFormat(True,3,1), FixFormat(True,3,0), FixRound.NonSymPos_s, FixSaturate.Sat_s))

    def test_OverflowDueRounding_Unsigned_Wrap(self):
        self.assertEqual(0.0, cl_fix_resize(7.5, FixFormat(False,3,1), FixFormat(False,3,0), FixRound.NonSymPos_s, FixSaturate.None_s))

    def test_OverflowDueRounding_Unsigned_Sat(self):
        self.assertEqual(7.0, cl_fix_resize(7.5, FixFormat(False,3,1), FixFormat(False,3,0), FixRound.NonSymPos_s, FixSaturate.Sat_s))

    def test_NonSymNeg_n05(self):
        self.assertEqual(-1.0, cl_fix_resize(-0.5, FixFormat(True,3,1), FixFormat(True,3,0), FixRound.NonSymNeg_s, FixSaturate.None_s))

    def test_NonSymNeg_n15(self):
        self.assertEqual(-2.0, cl_fix_resize(-1.5, FixFormat(True,3,1), FixFormat(True,3,0), FixRound.NonSymNeg_s, FixSaturate.None_s))

    def test_NonSymNeg_p05(self):
        self.assertEqual(0.0, cl_fix_resize(0.5, FixFormat(True,3,1), FixFormat(True,3,0), FixRound.NonSymNeg_s, FixSaturate.None_s))

    def test_NonSymNeg_p15(self):
        self.assertEqual(1.0, cl_fix_resize(1.5, FixFormat(True,3,1), FixFormat(True,3,0), FixRound.NonSymNeg_s, FixSaturate.None_s))

    def test_NonSymNeg_p175(self):
        self.assertEqual(2.0, cl_fix_resize(1.75, FixFormat(True,3,2), FixFormat(True,3,0), FixRound.NonSymNeg_s, FixSaturate.None_s))

    def test_SymInf_n05(self):
        self.assertEqual(-1.0, cl_fix_resize(-0.5, FixFormat(True,3,1), FixFormat(True,3,0), FixRound.SymInf_s, FixSaturate.None_s))

    def test_SymInf_n15(self):
        self.assertEqual(-2.0, cl_fix_resize(-1.5, FixFormat(True,3,1), FixFormat(True,3,0), FixRound.SymInf_s, FixSaturate.None_s))

    def test_SymInf_p05(self):
        self.assertEqual(1.0, cl_fix_resize(0.5, FixFormat(True,3,1), FixFormat(True,3,0), FixRound.SymInf_s, FixSaturate.None_s))

    def test_SymInf_p15(self):
        self.assertEqual(2.0, cl_fix_resize(1.5, FixFormat(True,3,1), FixFormat(True,3,0), FixRound.SymInf_s, FixSaturate.None_s))

    def test_SymInf_p175(self):
        self.assertEqual(2.0, cl_fix_resize(1.75, FixFormat(True,3,2), FixFormat(True,3,0), FixRound.SymInf_s, FixSaturate.None_s))

    def test_SymZero_n05(self):
        self.assertEqual(0.0, cl_fix_resize(-0.5, FixFormat(True,3,1), FixFormat(True,3,0), FixRound.SymZero_s, FixSaturate.None_s))

    def test_SymZero_n15(self):
        self.assertEqual(-1.0, cl_fix_resize(-1.5, FixFormat(True,3,1), FixFormat(True,3,0), FixRound.SymZero_s, FixSaturate.None_s))

    def test_SymZero_p05(self):
        self.assertEqual(0.0, cl_fix_resize(0.5, FixFormat(True,3,1), FixFormat(True,3,0), FixRound.SymZero_s, FixSaturate.None_s))

    def test_SymZero_p15(self):
        self.assertEqual(1.0, cl_fix_resize(1.5, FixFormat(True,3,1), FixFormat(True,3,0), FixRound.SymZero_s, FixSaturate.None_s))

    def test_SymZero_p175(self):
        self.assertEqual(2.0, cl_fix_resize(1.75, FixFormat(True,3,2), FixFormat(True,3,0), FixRound.SymZero_s, FixSaturate.None_s))

    def test_ConvEven_n05(self):
        self.assertEqual(0.0, cl_fix_resize(-0.5, FixFormat(True,3,1), FixFormat(True,3,0), FixRound.ConvEven_s, FixSaturate.None_s))

    def test_ConvEven_n15(self):
        self.assertEqual(-2.0, cl_fix_resize(-1.5, FixFormat(True,3,1), FixFormat(True,3,0), FixRound.ConvEven_s, FixSaturate.None_s))

    def test_ConvEven_p05(self):
        self.assertEqual(0.0, cl_fix_resize(0.5, FixFormat(True,3,1), FixFormat(True,3,0), FixRound.ConvEven_s, FixSaturate.None_s))

    def test_ConvEven_p15(self):
        self.assertEqual(2.0, cl_fix_resize(1.5, FixFormat(True,3,1), FixFormat(True,3,0), FixRound.ConvEven_s, FixSaturate.None_s))

    def test_ConvEven_p175(self):
        self.assertEqual(2.0, cl_fix_resize(1.75, FixFormat(True,3,2), FixFormat(True,3,0), FixRound.ConvEven_s, FixSaturate.None_s))

    def test_ConvOdd_n05(self):
        self.assertEqual(-1.0, cl_fix_resize(-0.5, FixFormat(True,3,1), FixFormat(True,3,0), FixRound.ConvOdd_s, FixSaturate.None_s))

    def test_ConvOdd_n15(self):
        self.assertEqual(-1.0, cl_fix_resize(-1.5, FixFormat(True,3,1), FixFormat(True,3,0), FixRound.ConvOdd_s, FixSaturate.None_s))

    def test_ConvOdd_p05(self):
        self.assertEqual(1.0, cl_fix_resize(0.5, FixFormat(True,3,1), FixFormat(True,3,0), FixRound.ConvOdd_s, FixSaturate.None_s))

    def test_ConvOdd_p15(self):
        self.assertEqual(1.0, cl_fix_resize(1.5, FixFormat(True,3,1), FixFormat(True,3,0), FixRound.ConvOdd_s, FixSaturate.None_s))

    def test_ConvOdd_p175(self):
        self.assertEqual(2.0, cl_fix_resize(1.75, FixFormat(True,3,2), FixFormat(True,3,0), FixRound.ConvOdd_s, FixSaturate.None_s))


### cl_fix_add ###
class cl_fix_add_Test(unittest.TestCase):

    def test_SameFmt_Signed(self):
        self.assertEqual(
            -2.5+1.25,
            cl_fix_add(  -2.5, FixFormat(True,5,3),
                        1.25, FixFormat(True,5,3),
                        FixFormat(True,5,3)))

    def test_SameFmt_Unigned(self):
        self.assertEqual(
            2.5 + 1.25,
            cl_fix_add(2.5, FixFormat(False, 5, 3),
                      1.25, FixFormat(False, 5, 3),
                      FixFormat(False, 5, 3)))

    def test_DiffIntBits_Signed(self):
        self.assertEqual(
            -2.5 + 1.25,
            cl_fix_add(-2.5, FixFormat(True, 6, 3),
                      1.25, FixFormat(True, 5, 3),
                      FixFormat(True, 5, 3)))

    def test_DiffIntBits_Unsigned(self):
        self.assertEqual(
            2.5 + 1.25,
            cl_fix_add(2.5, FixFormat(False, 6, 3),
                      1.25, FixFormat(False, 5, 3),
                      FixFormat(False, 5, 3)))

    def test_DiffFracBits_Signed(self):
        self.assertEqual(
            -2.5 + 1.25,
            cl_fix_add(-2.5, FixFormat(True, 5, 4),
                      1.25, FixFormat(True, 5, 3),
                      FixFormat(True, 5, 3)))

    def test_DiffFracBits_Unsigned(self):
        self.assertEqual(
            2.5 + 1.25,
            cl_fix_add(2.5, FixFormat(False, 5, 4),
                      1.25, FixFormat(False, 5, 3),
                      FixFormat(False, 5, 3)))

    def test_DiffRanges_Unsigned(self):
        self.assertEqual(
            0.75 + 4.0,
            cl_fix_add(0.75, FixFormat(False, 0, 4),
                      4.0, FixFormat(False, 4, -1),
                      FixFormat(False, 5, 5)))

    def test_Round(self):
        self.assertEqual(
            5.0,
            cl_fix_add(0.75, FixFormat(False, 0, 4),
                      4.0, FixFormat(False, 4, -1),
                      FixFormat(False, 5, 0), FixRound.NonSymPos_s))

    def test_Saturate(self):
        self.assertEqual(
            15.0,
            cl_fix_add(0.75, FixFormat(False, 0, 4),
                      15.0, FixFormat(False, 4, 0),
                      FixFormat(False, 4, 0), FixRound.NonSymPos_s, FixSaturate.Sat_s))

### cl_fix_sub ###
class cl_fix_sub_Test(unittest.TestCase):
    def test_SameFmt_Signed(self):
        self.assertEqual(
            -2.5-1.25,
            cl_fix_sub(-2.5, FixFormat(True,5,3),
                      1.25, FixFormat(True,5,3),
                      FixFormat(True,5,3)))

    def test_SameFmt_Unsigned(self):
        self.assertEqual(
            2.5 - 1.25,
            cl_fix_sub(2.5, FixFormat(False, 5, 3),
                      1.25, FixFormat(False, 5, 3),
                      FixFormat(False, 5, 3)))

    def test_DiffIntBits_Signed(self):
        self.assertEqual(
            -2.5 - 1.25,
            cl_fix_sub(-2.5, FixFormat(True, 6, 3),
                      1.25, FixFormat(True, 5, 3),
                      FixFormat(True, 5, 3)))

    def test_DiffIntBits_Unsigned(self):
        self.assertEqual(
            2.5 - 1.25,
            cl_fix_sub(2.5, FixFormat(False, 6, 3),
                      1.25, FixFormat(False, 5, 3),
                      FixFormat(False, 5, 3)))

    def test_DiffFracBits_Signed(self):
        self.assertEqual(
            -2.5 - 1.25,
            cl_fix_sub(-2.5, FixFormat(True, 5, 4),
                      1.25, FixFormat(True, 5, 3),
                      FixFormat(True, 5, 3)))

    def test_DiffFracBits_Unsigned(self):
        self.assertEqual(
            2.5 - 1.25,
            cl_fix_sub(2.5, FixFormat(False, 5, 4),
                      1.25, FixFormat(False, 5, 3),
                      FixFormat(False, 5, 3)))

    def test_DiffRanges_Unsigned(self):
        self.assertEqual(
            4.0 - 0.75,
            cl_fix_sub(4.0, FixFormat(False, 4, -1),
                      0.75, FixFormat(False, 0, 4),
                      FixFormat(False, 5, 5)))

    def test_Round(self):
        self.assertEqual(
            4.0,
            cl_fix_sub(4.0, FixFormat(False, 4, -1),
                      0.25, FixFormat(False, 0, 4),
                      FixFormat(False, 5, 0), FixRound.NonSymPos_s))

    def test_Saturate(self):
        self.assertEqual(
            0.0,
            cl_fix_sub(0.75, FixFormat(False, 0, 4),
                      5.0, FixFormat(False, 4, 0),
                      FixFormat(False, 4, 0), FixRound.NonSymPos_s, FixSaturate.Sat_s))

    def test_InvertMostNegative_Signed_NoSat(self):
        self.assertEqual(
            -16.0,
            cl_fix_sub(0.0, FixFormat(True, 4, 0),
                      -16, FixFormat(True, 4, 0),
                      FixFormat(True, 4, 0), FixRound.NonSymPos_s, FixSaturate.None_s))

    def test_InvertMostNegative_Signed_Sat(self):
        self.assertEqual(
            15.0,
            cl_fix_sub(0.0, FixFormat(True, 4, 0),
                      -16, FixFormat(True, 4, 0),
                      FixFormat(True, 4, 0), FixRound.NonSymPos_s, FixSaturate.Sat_s))

    def test_InvertMostNegative_Unsigned_NoSat(self):
        self.assertEqual(
            0.0,
            cl_fix_sub(0.0, FixFormat(False, 4, 0),
                      -16, FixFormat(False, 4, 0),
                      FixFormat(False, 4, 0), FixRound.NonSymPos_s, FixSaturate.None_s))

    def test_InvertUnsigned_Sat(self):
        self.assertEqual(
            0.0,
            cl_fix_sub(0.0, FixFormat(False, 4, 0),
                      15.0, FixFormat(False, 4, 0),
                      FixFormat(False, 4, 0), FixRound.NonSymPos_s, FixSaturate.Sat_s))

### cl_fix_mult ###
class cl_fix_mult_Test(unittest.TestCase):
    def test_AUnsignedPos_BUnsignedPos(self):
        self.assertEqual(
            2.5*1.25,
            cl_fix_mult(2.5, FixFormat(False, 5, 1),
                      1.25, FixFormat(False, 5, 2),
                      FixFormat(False, 5, 5)))

    def test_ASignedPos_BSignedPos(self):
        self.assertEqual(
            2.5 * 1.25,
            cl_fix_mult(2.5, FixFormat(True, 2, 1),
                       1.25, FixFormat(True, 1, 2),
                       FixFormat(True, 3, 3)))

    def test_ASignedPos_BSignedNeg(self):
        self.assertEqual(
            2.5 * (-1.25),
            cl_fix_mult(2.5, FixFormat(True, 2, 1),
                       -1.25, FixFormat(True, 1, 2),
                       FixFormat(True, 3, 3)))

    def test_ASignedNeg_BSignedPos(self):
        self.assertEqual(
            (-2.5) * 1.25,
            cl_fix_mult(-2.5, FixFormat(True, 2, 1),
                       1.25, FixFormat(True, 1, 2),
                       FixFormat(True, 3, 3)))

    def test_ASignedNeg_BSignedNeg(self):
        self.assertEqual(
            (-2.5) * (-1.25),
            cl_fix_mult(-2.5, FixFormat(True, 2, 1),
                       -1.25, FixFormat(True, 1, 2),
                       FixFormat(True, 3, 3)))

    def test_AUnsignedPos_BSignedPos(self):
        self.assertEqual(
            2.5 * 1.25,
            cl_fix_mult(2.5, FixFormat(False, 2, 1),
                       1.25, FixFormat(True, 1, 2),
                       FixFormat(True, 3, 3)))

    def test_AUnsignedPos_BSignedNeg(self):
        self.assertEqual(
            2.5 * (-1.25),
            cl_fix_mult(2.5, FixFormat(False, 2, 1),
                       -1.25, FixFormat(True, 1, 2),
                       FixFormat(True, 3, 3)))

    def test_AUnsignedPos_BSignedPos_ResultUnsigned(self):
        self.assertEqual(
            2.5 * 1.25,
            cl_fix_mult(2.5, FixFormat(False, 2, 1),
                       1.25, FixFormat(True, 1, 2),
                       FixFormat(False, 3, 3)))

    def test_AUnsignedPos_BSignedPos_Saturate(self):
        self.assertEqual(
            1.875,
            cl_fix_mult(2.5, FixFormat(False, 2, 1),
                       1.25, FixFormat(True, 1, 2),
                       FixFormat(False, 1, 3), FixRound.Trunc_s, FixSaturate.Sat_s))

### cl_fix_abs ###
class cl_fix_abs_test(unittest.TestCase):

    def test_Positive_Stay_Positive(self):
        self.assertEqual(2.5, cl_fix_abs(2.5, FixFormat(False,5,1), FixFormat(False,5,1)))

    def test_Negative_Becomes_Positive(self):
        self.assertEqual(4.0, cl_fix_abs(-4.0, FixFormat(True, 2, 2), FixFormat(True, 3, 3)))

    def test_Most_Negative_Value_Sat(self):
        self.assertEqual(3.75, cl_fix_abs(-4.0, FixFormat(True, 2, 2), FixFormat(True, 2, 2), FixRound.Trunc_s, FixSaturate.Sat_s))

### cl_fix_neg ###
class cl_fix_neg_Test(unittest.TestCase):

    def test_PositiveToNegative_SignedToSigned(self):
        self.assertEqual(-2.5, cl_fix_neg(2.5, FixFormat(True,5,1), FixFormat(True,5,5)))

    def test_PositiveToNegative_UnsignedToSigned(self):
        self.assertEqual(-2.5, cl_fix_neg(2.5, FixFormat(False, 5, 1), FixFormat(True, 5, 5)))

    def test_NegativeToPositive_SignedToSigned(self):
        self.assertEqual(2.5, cl_fix_neg(-2.5, FixFormat(True, 5, 1), FixFormat(True, 5, 5)))

    def test_NegativeToPositive_SignedToUnsigned(self):
        self.assertEqual(2.5, cl_fix_neg(-2.5, FixFormat(True, 5, 1), FixFormat(False, 5, 5)))

    def test_Saturation_SignedToSigned(self):
        self.assertEqual(3.75, cl_fix_neg(-4.0, FixFormat(True, 2, 4), FixFormat(True, 2, 2), FixRound.Trunc_s, FixSaturate.Sat_s))

    def test_Wrap_SignedToSigned(self):
        self.assertEqual(-4.0, cl_fix_neg(-4.0, FixFormat(True, 2, 4), FixFormat(True, 2, 2), FixRound.Trunc_s, FixSaturate.None_s))

    def test_PosToNegSaturate_SignedToUnsigned(self):
        self.assertEqual(0.0, cl_fix_neg(2.5, FixFormat(True, 5, 1), FixFormat(False, 5, 5), FixRound.Trunc_s, FixSaturate.Sat_s))

#### cl_fix_shift (left) ###
class cl_fix_shift_left_Test(unittest.TestCase):

    def test_SameFmt_Unsigned(self):
        self.assertEqual(
            2.5,
            cl_fix_shift(1.25, FixFormat(False,3,2),
                         1,
                         FixFormat(False,3,2)))

    def test_SameFmt_Signed(self):
        self.assertEqual(
            2.5,
            cl_fix_shift(1.25, FixFormat(True, 3, 2),
                         1,
                         FixFormat(True, 3, 2)))

    def test_FmtChange(self):
        self.assertEqual(
            2.5,
            cl_fix_shift(1.25, FixFormat(True, 1, 2),
                         1,
                         FixFormat(False, 3, 2)))

    def test_Saturation_Signed(self):
        self.assertEqual(
            3.75,
            cl_fix_shift(2.0, FixFormat(True, 2, 2),
                         1,
                         FixFormat(False, 2, 2), FixRound.Trunc_s, FixSaturate.Sat_s))

    def test_Saturation_UnsignedToSigned(self):
        self.assertEqual(
            3.75,
            cl_fix_shift(2.0, FixFormat(False, 3, 2),
                         1,
                         FixFormat(True, 2, 2), FixRound.Trunc_s, FixSaturate.Sat_s))

    def test_Saturation_SignedToUnsigned(self):
        self.assertEqual(
            0.0,
            cl_fix_shift(-0.5, FixFormat(True, 3, 2),
                         1,
                         FixFormat(False, 2, 2), FixRound.Trunc_s, FixSaturate.Sat_s))

    def test_Wrap_Signed(self):
        self.assertEqual(
            -4.0,
            cl_fix_shift(2.0, FixFormat(True, 2, 2),
                         1,
                         FixFormat(True, 2, 2), FixRound.Trunc_s, FixSaturate.None_s))

    def test_Wrap_UnsignedToSigned(self):
        self.assertEqual(
            -4.0,
            cl_fix_shift(2.0, FixFormat(False, 3, 2),
                         1,
                         FixFormat(True, 2, 2), FixRound.Trunc_s, FixSaturate.None_s))

    def test_Wrap_SignedToUnsigned(self):
        self.assertEqual(
            3.0,
            cl_fix_shift(-0.5, FixFormat(True, 3, 2),
                         1,
                         FixFormat(False, 2, 2), FixRound.Trunc_s, FixSaturate.None_s))

    def test_Shift0(self):
        self.assertEqual(
            0.5,
            cl_fix_shift(0.5, FixFormat(True, 5, 5),
                         0,
                         FixFormat(True, 5, 5), FixRound.Trunc_s, FixSaturate.None_s))

    def test_Shift3(self):
        self.assertEqual(
            -4.0,
            cl_fix_shift(-0.5, FixFormat(True, 5, 5),
                         3,
                         FixFormat(True, 5, 5), FixRound.Trunc_s, FixSaturate.None_s))

### cl_fix_shift (right) ###
class cl_fix_shift_right_Test(unittest.TestCase):

    def test_SameFmt_Unsigned(self):
        self.assertEqual(
            1.25,
            cl_fix_shift(2.5, FixFormat(False, 3, 2),
                         -1,
                         FixFormat(False, 3, 2)))

    def test_SameFmt_Signed(self):
        self.assertEqual(
            1.25,
            cl_fix_shift(2.5, FixFormat(True, 3, 2),
                         -1,
                         FixFormat(True, 3, 2)))

    def test_FmtChange(self):
        self.assertEqual(
            1.25,
            cl_fix_shift(2.5, FixFormat(False, 3, 2),
                         -1,
                         FixFormat(True, 1, 2)))

    def test_Saturation_SignedToUnsigned(self):
        self.assertEqual(
            0.0,
            cl_fix_shift(-0.5, FixFormat(True, 3, 2),
                         -1,
                         FixFormat(False, 2, 2), FixRound.Trunc_s, FixSaturate.Sat_s))

    def test_Saturation_Shift0(self):
        self.assertEqual(
            0.5,
            cl_fix_shift(0.5, FixFormat(True, 5, 5),
                         0,
                         FixFormat(True, 5, 5), FixRound.Trunc_s, FixSaturate.None_s))

    def test_Saturation_Shift3(self):
        self.assertEqual(
            -0.5,
            cl_fix_shift(-4.0, FixFormat(True, 5, 5),
                         -3,
                         FixFormat(True, 5, 5), FixRound.Trunc_s, FixSaturate.None_s))


### cl_fix_max_value ###
class cl_fix_max_value_Test(unittest.TestCase):

    def test_Unsigned(self):
        self.assertEqual(3.75, cl_fix_max_value(FixFormat(False,2,2)))

    def test_Signed(self):
        self.assertEqual(1.75, cl_fix_max_value(FixFormat(True, 1, 2)))

### cl_fix_min_value ###
class cl_fix_min_value_Test(unittest.TestCase):
    def test_Unsigned(self):
        self.assertEqual(0.0, cl_fix_min_value(FixFormat(False, 2, 2)))

    def test_Signed(self):
        self.assertEqual(-2.0, cl_fix_min_value(FixFormat(True, 1, 2)))

### cl_fix_in_range ###
class cl_fix_in_range_Test(unittest.TestCase):

    def test_InRangeNormal(self):
        self.assertEqual(True, cl_fix_in_range(1.25, FixFormat(True,4,2), FixFormat(True,2,4), FixRound.Trunc_s))

    def test_OutRangeNormal(self):
        self.assertEqual(False, cl_fix_in_range(6.25, FixFormat(True,4,2), FixFormat(True,2,4), FixRound.Trunc_s))

    def test_SignedUnsigned_OutRange(self):
        self.assertEqual(False, cl_fix_in_range(-1.25, FixFormat(True,4,2), FixFormat(False,5,2), FixRound.Trunc_s))

    def test_UnsignedSigned_OutRange(self):
        self.assertEqual(False, cl_fix_in_range(15.0, FixFormat(False,4,2), FixFormat(True,3,2), FixRound.Trunc_s))

    def test_UnsignedSigned_InRange(self):
        self.assertEqual(True, cl_fix_in_range(15.0, FixFormat(False,4,2), FixFormat(True,4,2), FixRound.Trunc_s))

    def test_Rounding_OutRange(self):
        self.assertEqual(False, cl_fix_in_range(15.5, FixFormat(False,4,2), FixFormat(True,4,0), FixRound.NonSymPos_s))

    def test_Rounding_InRange1(self):
        self.assertEqual(True, cl_fix_in_range(15.5, FixFormat(False,4,2), FixFormat(True,4,1), FixRound.NonSymPos_s))

    def test_Rounding_InRange2(self):
        self.assertEqual(True, cl_fix_in_range(15.5, FixFormat(False,4,2), FixFormat(False,5,0), FixRound.NonSymPos_s))

### cl_fix_sign ###
class cl_fix_sign_Test(unittest.TestCase):
    def test_Unsigned(self):
        self.assertEqual(0, cl_fix_sign(3.25, FixFormat(False, 2, 2)))

    def test_SignedOne(self):
        self.assertEqual(1, cl_fix_sign(-1.25, FixFormat(True, 2, 2)))

    def test_SignedZero(self):
        self.assertEqual(0, cl_fix_sign(3.25, FixFormat(True, 2, 2)))

### cl_fix_int ###
class cl_fix_int_Test(unittest.TestCase):
    def test_Unsigned(self):
        self.assertEqual(3, cl_fix_int(3.25, FixFormat(False, 2, 2)))

    def test_SignedPos(self):
        self.assertEqual(3, cl_fix_int(3.25, FixFormat(True, 2, 2)))

    def test_SignedNeg(self):
        self.assertEqual(-2, cl_fix_int(-1.25, FixFormat(True, 2, 2)))

### cl_fix_frac ###
class cl_fix_frac_Test(unittest.TestCase):
    def test_Unsigned(self):
        self.assertEqual(0.25, cl_fix_frac(3.25, FixFormat(False, 2, 3)))

### cl_fix_combine ###
class cl_fix_combine_Test(unittest.TestCase):
    def test_Unsigned(self):
        self.assertEqual(-3.25, cl_fix_combine(1, 0, 3, FixFormat(True,2,2)))

### cl_fix_get_msb ###
class cl_fix_get_msb_Test(unittest.TestCase):
    def test_One(self):
        self.assertEqual(1, cl_fix_get_msb(2.25, FixFormat(True, 3, 3), 2))

    def test_Zero(self):
        self.assertEqual(0, cl_fix_get_msb(2.25, FixFormat(True, 3, 3), 1))

### cl_fix_get_lsb ###
class cl_fix_get_lsb_Test(unittest.TestCase):
    def test_One(self):
        self.assertEqual(1, cl_fix_get_lsb(2.25, FixFormat(True, 3, 3), 1))

    def test_Zero(self):
        self.assertEqual(0, cl_fix_get_lsb(2.25, FixFormat(True, 3, 3), 2))

### cl_fix_set_msb ###
class cl_fix_set_msb_Test(unittest.TestCase):
    def test_SetOne(self):
        self.assertEqual(2.25, cl_fix_set_msb(2.25, FixFormat(True, 3, 3), 2, 1))

    def test_SetZero(self):
        self.assertEqual(6.25, cl_fix_set_msb(2.25, FixFormat(True, 3, 3), 1, 1))

    def test_ClearOne(self):
        self.assertEqual(0.25, cl_fix_set_msb(2.25, FixFormat(True, 3, 3), 2, 0))

    def test_ClearZero(self):
        self.assertEqual(2.25, cl_fix_set_msb(2.25, FixFormat(True, 3, 3), 1, 0))

### cl_fix_set_lsb ###
class cl_fix_set_lsb_Test(unittest.TestCase):
    def test_SetOne(self):
        self.assertEqual(2.25, cl_fix_set_lsb(2.25, FixFormat(True, 3, 3), 1, 1))

    def test_SetZero(self):
        self.assertEqual(2.75, cl_fix_set_lsb(2.25, FixFormat(True, 3, 3), 2, 1))

    def test_ClearOne(self):
        self.assertEqual(2.0, cl_fix_set_lsb(2.25, FixFormat(True, 3, 3), 1, 0))

    def test_ClearZero(self):
        self.assertEqual(2.25, cl_fix_set_lsb(2.25, FixFormat(True, 3, 3), 2, 0))

### cl_fix_sabs ###
class cl_fix_sabs_Test(unittest.TestCase):
    def test_Positive(self):
        self.assertEqual(2.25, cl_fix_sabs(2.25, FixFormat(True, 3, 3), FixFormat(False, 2, 2)))

    def test_Negative(self):
        self.assertEqual(2.0, cl_fix_sabs(-2.25, FixFormat(True, 3, 3), FixFormat(False, 2, 2)))

### cl_fix_sneg ###
class cl_fix_sneg_Test(unittest.TestCase):
    def test_Array(self):
        result = cl_fix_sneg(np.array([2.25, -2.25]), FixFormat(True, 3, 3), True, FixFormat(True, 3, 2))
        self.assertEqual(-2.5, result[0])
        self.assertEqual(2.0, result[1])

### cl_fix_addsub ###
class cl_fix_addsub_Test(unittest.TestCase):
    def test_Array(self):
        result = cl_fix_addsub(np.array([1.0, 1.25]), FixFormat(True, 3, 3),
                               np.array([0.75, 0.25]), FixFormat(True, 3, 3),
                               np.array([True, False]), FixFormat(True, 3, 3))
        self.assertEqual(1.75, result[0])
        self.assertEqual(1.0, result[1])

### cl_fix_saddsub ###
class cl_fix_saddsub_Test(unittest.TestCase):
    def test_Array(self):
        result = cl_fix_saddsub(np.array([1.0, 1.25]), FixFormat(True, 3, 2),
                                np.array([0.75, 0.25]), FixFormat(True, 3, 2),
                                np.array([True, False]), FixFormat(True, 3, 2))
        self.assertEqual(1.75, result[0])
        self.assertEqual(0.75, result[1])


########################################################################################################################
# Test Runner
########################################################################################################################
if __name__ == "__main__":
    unittest.main()




