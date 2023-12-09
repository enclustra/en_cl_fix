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

def sat_check(a, a_fmt, r_fmt, sat):
    # Copy array
    a = a.copy()
    
    assert r_fmt.F == a_fmt.F, "Number of fractional bits cannot change"
    
    if sat is FixSaturate.None_s or sat is FixSaturate.Warn_s:
        # No saturation. Wrap into range.
        min_r = cl_fix_min_value(r_fmt)
        max_r = cl_fix_max_value(r_fmt)
        offset = 2.0 ** (r_fmt.S + r_fmt.I)
        for i in range(len(a)):
            while a[i] < min_r:
                a[i] += offset
            while a[i] > max_r:
                a[i] -= offset
        return a
    elif sat is FixSaturate.Sat_s or sat is FixSaturate.SatWarn_s:
        # Saturation
        a = np.where(a > cl_fix_max_value(r_fmt), cl_fix_max_value(r_fmt), a)
        a = np.where(a < cl_fix_min_value(r_fmt), cl_fix_min_value(r_fmt), a)
        return a
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
rS_values = [0,1]
rI_values = np.arange(-4,1+4)

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
            
            for rS in rS_values:
                for rI in rI_values:
                    rF = aF
                    
                    # Skip invalid formats
                    try:
                        r_fmt = FixFormat(rS, rI, rF)
                    except AssertionError:
                        continue
                    
                    for sat in FixSaturate:
                        # Calculate using cl_fix_saturate
                        r = cl_fix_saturate(a, a_fmt, r_fmt, sat)
                        
                        # Repeat using WideFix (but still with narrow data)
                        r_wide = WideFix.FromNarrowFxp(a, a_fmt).saturate(r_fmt, sat).to_real()
                        
                        # Local checker function
                        expected = sat_check(a, a_fmt, r_fmt, sat)
                        
                        # Check numerical correctness
                        assert np.array_equal(r, expected), "Numerical error detected."
                        assert np.array_equal(r_wide, expected), "Numerical error detected (WideFix)."
                        
                        test_count += 1

print(f"Completed {test_count} tests.")