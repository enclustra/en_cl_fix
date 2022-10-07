###################################################################################################
# Copyright (c) 2022 Enclustra GmbH, Switzerland (info@enclustra.com)
###################################################################################################

###################################################################################################
# Imports
###################################################################################################
import sys
import os
from os.path import join, dirname
root = dirname(__file__)
sys.path.append(join(root, "../../models/python"))
from shutil import rmtree
from en_cl_fix_pkg import *

import numpy as np

###################################################################################################
# Config
###################################################################################################

# Clear data directory
DATA_DIR = join(root, "data")
try:
    rmtree(DATA_DIR)
except FileNotFoundError:
    pass
os.mkdir(DATA_DIR)

# aFmt test points
aS_values = [0,1]
aI_values = np.arange(-4,1+4)
aF_values = np.arange(-4,1+4)

# rFmt test points
rS_values = [0,1]
rI_values = np.arange(-4,1+4)

###################################################################################################
# Helpers
###################################################################################################

def get_data(fmt : FixFormat):
    # Generate every possible value in format (counter)
    int_min = cl_fix_to_integer(cl_fix_min_value(fmt), fmt)
    int_max = cl_fix_to_integer(cl_fix_max_value(fmt), fmt)
    int_data = np.arange(int_min, 1+int_max)
    return cl_fix_from_integer(int_data, fmt)

###################################################################################################
# Run
###################################################################################################

test_count = 0

test_aFmt = []
test_rFmt = []
test_sat = []

########
# aFmt #
########
for aS in aS_values:
    for aI in aI_values:
        for aF in aF_values:
            # Skip unusable formats
            if aS+aI+aF <= 0:
                continue
            
            aFmt = FixFormat(aS, aI, aF)
            
            # Generate A data
            a = get_data(aFmt)
            
            ########
            # rFmt #
            ########
            for rS in rS_values:
                for rI in rI_values:
                    rF = aF
                    
                    # Skip any parameter combinations that lead to invalid internal formats
                    try:
                        rFmt = FixFormat(rS, rI, rF)
                    except:
                        continue
                    
                    # Also skip any zero-width formats (we need some data to check)
                    if cl_fix_width(rFmt) == 0:
                        continue
                    
                    #######
                    # sat #
                    #######
                    for sat in FixSaturate:
                        
                        # Calculate output
                        r = cl_fix_saturate(a, aFmt, rFmt, sat)
                        
                        # Save output to file
                        np.savetxt(join(DATA_DIR, f"test{test_count}_output.txt"),
                                   cl_fix_to_integer(r, rFmt),
                                   fmt="%i", header=f"r[{r.size}]")
                        
                        # Save test parameters into lists
                        test_aFmt.append(aFmt)
                        test_rFmt.append(rFmt)
                        test_sat.append(sat.value)
                        
                        test_count += 1

print(f"Cosim generated {test_count} tests.")

# Save formats
aFmt_names = ["aFmt" + str(i) for i in range(test_count)]
cl_fix_write_formats(test_aFmt, aFmt_names, join(DATA_DIR, f"aFmt.txt"))

rFmt_names = ["rFmt" + str(i) for i in range(test_count)]
cl_fix_write_formats(test_rFmt, rFmt_names, join(DATA_DIR, f"rFmt.txt"))

# Save rounding and saturation modes
np.savetxt(join(DATA_DIR, f"sat.txt"), test_sat, fmt="%i", header=f"Saturation modes")
