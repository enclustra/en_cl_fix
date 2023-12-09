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
    int_min = cl_fix_to_integer(cl_fix_min_value(fmt), fmt)
    int_max = cl_fix_to_integer(cl_fix_max_value(fmt), fmt)
    int_data = np.arange(int_min, 1+int_max)
    return cl_fix_from_integer(int_data, fmt)

def round_check(a, a_fmt, r_fmt, rnd):
    # Copy array
    a = a.copy()
    
    def NonSymPos(a, a_fmt, r_fmt):
        a = a + 2.0**-(r_fmt.F+1)
        return np.floor(a * 2.0**r_fmt.F) / 2.0**r_fmt.F
    
    def NonSymNeg(a, a_fmt, r_fmt):
        a = a - 2.0**-(r_fmt.F+1)
        return np.ceil(a * 2.0**r_fmt.F) / 2.0**r_fmt.F
        
    if rnd is FixRound.Trunc_s:
        return np.floor(a * 2.0**r_fmt.F) / 2.0**r_fmt.F
    elif rnd is FixRound.NonSymPos_s:
        return NonSymPos(a, a_fmt, r_fmt)
    elif rnd is FixRound.NonSymNeg_s:
        return NonSymNeg(a, a_fmt, r_fmt)
    elif rnd is FixRound.SymInf_s:
        return np.where(a >= 0, NonSymPos(a, a_fmt, r_fmt), NonSymNeg(a, a_fmt, r_fmt))
    elif rnd is FixRound.SymZero_s:
        return np.where(a >= 0, NonSymNeg(a, a_fmt, r_fmt), NonSymPos(a, a_fmt, r_fmt))
    elif rnd is FixRound.ConvEven_s:
        # Numpy's around() implements convergent even rounding
        return np.around(a * 2.0**r_fmt.F) / 2.0**r_fmt.F
    elif rnd is FixRound.ConvOdd_s:
        # Offset +1, do convergent even rounding, then -1 again
        return (np.around(a * 2.0**r_fmt.F + 1) - 1) / 2.0**r_fmt.F
    else:
        raise ValueError(f"Unrecognized rounding mode: {rnd}")

###################################################################################################
# Config
###################################################################################################

# a_fmt test points
aS_values = [0,1]
aI_values = np.arange(-4,1+4)
aF_values = np.arange(-4,1+4)

# r_fmt test points
rF_values = np.arange(-4,1+4)

###################################################################################################
# Run
###################################################################################################

test_count = 0

#########
# a_fmt #
#########
for aS in aS_values:
    for aI in aI_values:
        for aF in aF_values:
            # Skip invalid formats
            if aS+aI+aF <= 0:
                continue
            
            a_fmt = FixFormat(aS, aI, aF)
            
            # Generate A data
            a = get_data(a_fmt)
            
            for rF in rF_values:
                for rnd in FixRound:
                    # Skip invalid formats
                    try:
                        r_fmt = FixFormat.ForRound(a_fmt, rF, rnd)
                    except AssertionError:
                        continue
                    
                    # Calculate using cl_fix_round
                    r = cl_fix_round(a, a_fmt, r_fmt, rnd)
                    
                    # Repeat using WideFix (but still with narrow data)
                    r_wide = WideFix.from_narrowfix(a, a_fmt).round(r_fmt, rnd).to_real()
                    
                    # Local checker function
                    expected = round_check(a, a_fmt, r_fmt, rnd)
                    
                    # Check numerical correctness
                    assert np.array_equal(r, expected), "Numerical error detected."
                    assert np.array_equal(r_wide, expected), "Numerical error detected (WideFix)."
                    
                    test_count += 1

print(f"Completed {test_count} tests.")