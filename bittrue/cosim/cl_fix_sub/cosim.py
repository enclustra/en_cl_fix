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
from en_cl_fix_pkg import *

import numpy as np

###################################################################################################
# Config
###################################################################################################

# Create data directory
DATA_DIR = join(root, "data")
try:
    os.mkdir(DATA_DIR)
except FileExistsError:
    pass

# aFmt test points
aS_values = [0,1]
aI_values = np.arange(-1,1+4)
aIplusF = 3

# bFmt test points
bS_values = [0,1]
bI_values = np.arange(-1,1+4)
bIplusF = 3

# rFmt test points
rS_values = [0,1]
rI_values = np.arange(-1,1+4)
rIplusF = 3

# rnd test points
rnd_values = [FixRound.Trunc_s, FixRound.NonSymPos_s]

# sat test points
sat_values = [FixSaturate.None_s, FixSaturate.Sat_s]

###################################################################################################
# Helpers
###################################################################################################

def get_data(fmt : FixFormat):
    # Generate every possible value in format (counter)
    int_min = cl_fix_get_bits_as_int(cl_fix_min_value(fmt), fmt)
    int_max = cl_fix_get_bits_as_int(cl_fix_max_value(fmt), fmt)
    int_data = np.arange(int_min, 1+int_max)
    return cl_fix_from_bits_as_int(int_data, fmt)

def repeat_each_value(x, n):
    return np.tile(x, (n,1)).flatten(order='F')

def repeat_whole_array(x, n):
    return np.tile(x, (n,1)).flatten(order='C')

###################################################################################################
# Run
###################################################################################################

test_count = 0

test_aFmt = []
test_bFmt = []
test_rFmt = []
test_rnd = []
test_sat = []

########
# aFmt #
########
for aS in aS_values:
    for aI in aI_values:
        # Limit I+F (to keep simulation time reasonable)
        aF = aIplusF-aI
        aFmt = FixFormat(aS, aI, aF)
        
        # Generate A data
        a = get_data(aFmt)
        
        ########
        # bFmt #
        ########
        for bS in bS_values:
            for bI in bI_values:
                # Limit I+F (to keep simulation time reasonable)
                bF = bIplusF-bI
                bFmt = FixFormat(bS, bI, bF)
                
                # Generate B data
                b = get_data(bFmt)
                
                # Produce all combinations of all a and b values
                a_all = repeat_whole_array(a, len(b))
                b_all = repeat_each_value(b, len(a))
                
                ########
                # rFmt #
                ########
                for rS in rS_values:
                    for rI in rI_values:
                        # Limit I+F (to keep simulation time reasonable)
                        rF = rIplusF-rI
                        rFmt = FixFormat(rS, rI, rF)
                        
                        #######
                        # rnd #
                        #######
                        for rnd in rnd_values:
                            
                            #######
                            # sat #
                            #######
                            for sat in sat_values:
                                # Calculate output
                                r = cl_fix_sub(a_all, aFmt, b_all, bFmt, rFmt, rnd, sat)
                                
                                # Save output to file
                                np.savetxt(join(DATA_DIR, f"test{test_count}_output.txt"),
                                           cl_fix_get_bits_as_int(r, rFmt),
                                           fmt="%i", header=f"r[{r.size}]")
                                
                                # Save test parameters into lists
                                test_aFmt.append(aFmt)
                                test_bFmt.append(bFmt)
                                test_rFmt.append(rFmt)
                                test_rnd.append(rnd.value)
                                test_sat.append(sat.value)
                                
                                test_count += 1

# Save formats
aFmt_names = ["aFmt" + str(i) for i in range(test_count)]
cl_fix_write_formats(test_aFmt, aFmt_names, join(DATA_DIR, f"aFmt.txt"))

bFmt_names = ["bFmt" + str(i) for i in range(test_count)]
cl_fix_write_formats(test_bFmt, bFmt_names, join(DATA_DIR, f"bFmt.txt"))

rFmt_names = ["rFmt" + str(i) for i in range(test_count)]
cl_fix_write_formats(test_rFmt, rFmt_names, join(DATA_DIR, f"rFmt.txt"))

# Save rounding and saturation modes
np.savetxt(join(DATA_DIR, f"rnd.txt"), test_rnd, fmt="%i", header=f"Rounding modes")
np.savetxt(join(DATA_DIR, f"sat.txt"), test_sat, fmt="%i", header=f"Saturation modes")
