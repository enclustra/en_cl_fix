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
aI_values = np.arange(-3,1+3)
aF_values = np.arange(-3,1+3)

# bFmt test points
bS_values = [0,1]
bI_values = np.arange(-3,1+3)
bF_values = np.arange(-3,1+3)

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
        for aF in aF_values:
            # Skip formats with non-positive length
            if aS+aI+aF <= 0:
                continue
            
            aFmt = FixFormat(aS, aI, aF)
            
            # Generate A data
            a = get_data(aFmt)
            
            ########
            # bFmt #
            ########
            for bS in bS_values:
                for bI in bI_values:
                    for bF in bF_values:
                        # Skip formats with non-positive length
                        if bS+bI+bF <= 0:
                            continue
                        
                        bFmt = FixFormat(bS, bI, bF)
                        
                        # Generate B data
                        b = get_data(bFmt)
                        
                        # Produce all combinations of all a and b values
                        a_all = repeat_whole_array(a, len(b))
                        b_all = repeat_each_value(b, len(a))
                        
                        # Calculate outputs
                        r_eq = a_all == b_all
                        r_neq = a_all != b_all
                        r_less = a_all < b_all
                        r_greater = a_all > b_all
                        r_leq = a_all <= b_all
                        r_geq = a_all >= b_all
                        
                        # Save outputs to file
                        np.savetxt(join(DATA_DIR, f"test{test_count}_eq.txt"),
                                   r_eq.astype(int),
                                   fmt="%i", header=f"r_eq[{r_eq.size}]")
                        np.savetxt(join(DATA_DIR, f"test{test_count}_neq.txt"),
                                   r_neq.astype(int),
                                   fmt="%i", header=f"r_neq[{r_neq.size}]")
                        np.savetxt(join(DATA_DIR, f"test{test_count}_less.txt"),
                                   r_less.astype(int),
                                   fmt="%i", header=f"r_less[{r_less.size}]")
                        np.savetxt(join(DATA_DIR, f"test{test_count}_greater.txt"),
                                   r_greater.astype(int),
                                   fmt="%i", header=f"r_greater[{r_greater.size}]")
                        np.savetxt(join(DATA_DIR, f"test{test_count}_leq.txt"),
                                   r_leq.astype(int),
                                   fmt="%i", header=f"r_leq[{r_leq.size}]")
                        np.savetxt(join(DATA_DIR, f"test{test_count}_geq.txt"),
                                   r_geq.astype(int),
                                   fmt="%i", header=f"r_geq[{r_geq.size}]")
                        
                        # Save test parameters into lists
                        test_aFmt.append(aFmt)
                        test_bFmt.append(bFmt)
                        
                        test_count += 1

# Save formats
aFmt_names = ["aFmt" + str(i) for i in range(test_count)]
cl_fix_write_formats(test_aFmt, aFmt_names, join(DATA_DIR, f"aFmt.txt"))

bFmt_names = ["bFmt" + str(i) for i in range(test_count)]
cl_fix_write_formats(test_bFmt, bFmt_names, join(DATA_DIR, f"bFmt.txt"))
