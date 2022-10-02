###################################################################################################
# Copyright (c) 2022 Enclustra GmbH, Switzerland (info@enclustra.com)
###################################################################################################

###################################################################################################
# Description:
#
# This script tests cl_fix_round against standard Python implementations.
###################################################################################################

###################################################################################################
# Imports
###################################################################################################
import sys
import os
from os.path import join, dirname
root = dirname(__file__)
sys.path.append(join(root, "../../models/python"))
from en_cl_fix_pkg import *

import numpy as np

###################################################################################################
# Helpers
###################################################################################################

def get_data(fmt : FixFormat):
    # Generate every possible value in format (counter)
    int_min = cl_fix_get_bits_as_int(cl_fix_min_value(fmt), fmt)
    int_max = cl_fix_get_bits_as_int(cl_fix_max_value(fmt), fmt)
    int_data = np.arange(int_min, 1+int_max)
    return cl_fix_from_bits_as_int(int_data, fmt)

def round_check(a, aFmt, rFmt, rnd):
    # Copy array
    a = a.copy()
    
    def NonSymPos(a, aFmt, rFmt, rnd):
        a = a + 2.0**-(rFmt.F+1)
        return np.floor(a * 2.0**rFmt.F) / 2.0**rFmt.F
    
    def NonSymNeg(a, aFmt, rFmt, rnd):
        a = a - 2.0**-(rFmt.F+1)
        return np.ceil(a * 2.0**rFmt.F) / 2.0**rFmt.F
    
    if rnd is FixRound.Trunc_s:
        return np.floor(a * 2.0**rFmt.F) / 2.0**rFmt.F
    elif rnd is FixRound.NonSymPos_s:
        return NonSymPos(a, aFmt, rFmt, rnd)
    elif rnd is FixRound.NonSymNeg_s:
        return NonSymNeg(a, aFmt, rFmt, rnd)
    elif rnd is FixRound.SymInf_s:
        return np.where(a >= 0, NonSymPos(a, aFmt, rFmt, rnd), NonSymNeg(a, aFmt, rFmt, rnd))
    elif rnd is FixRound.SymZero_s:
        return np.where(a >= 0, NonSymNeg(a, aFmt, rFmt, rnd), NonSymPos(a, aFmt, rFmt, rnd))
    elif rnd is FixRound.ConvEven_s:
        # Numpy's around() implements convergent even rounding
        return np.around(a * 2.0**rFmt.F) / 2.0**rFmt.F
    elif rnd is FixRound.ConvOdd_s:
        # Offset +1, do convergent even rounding, then -1 again
        return (np.around(a * 2.0**rFmt.F + 1) - 1) / 2.0**rFmt.F
    else:
        raise ValueError(f"Unrecognized rounding mode: {rnd}")

###################################################################################################
# Config
###################################################################################################

# aFmt test points
aS_values = [0,1]
aI_values = np.arange(-4,1+4)
aF_values = np.arange(-4,1+4)

# rFmt test points
rF_values = np.arange(-4,1+4)

###################################################################################################
# Run
###################################################################################################

test_count = 0

########
# aFmt #
########
for aS in aS_values:
    for aI in aI_values:
        for aF in aF_values:
            # Skip invalid formats
            try:
                aFmt = FixFormat(aS, aI, aF)
            except AssertionError:
                continue
            
            # Generate A data
            a = get_data(aFmt)
            
            for rF in rF_values:
                for rnd in FixRound:
                    # Skip invalid formats
                    try:
                        rFmt = FixFormat.ForRound(aFmt, rF, rnd)
                    except AssertionError:
                        continue
                    
                    # Calculate using cl_fix_round
                    r = cl_fix_round(a, aFmt, rFmt, rnd)
                    
                    # Repeat using wide_fxp (but still with narrow data)
                    r_wide = cl_fix_round(wide_fxp.FromNarrowFxp(a, aFmt), aFmt, rFmt, rnd)
                    
                    # Local checker function
                    expected = round_check(a, aFmt, rFmt, rnd)
                    
                    # Check numerical correctness
                    assert np.array_equal(r, expected), "Numerical error detected."
                    assert np.array_equal(r_wide, expected), "Numerical error detected (wide_fxp)."
                    
                    test_count += 1

print(f"Completed {test_count} tests.")