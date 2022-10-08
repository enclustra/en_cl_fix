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
import numpy as np

sys.path.append(join(root, "../../models/python"))
from en_cl_fix_pkg import *

sys.path.append(join(root, ".."))
from cosim_utils import *

# Clear data directory
DATA_DIR = join(root, "data")
clear_directory(DATA_DIR)

###################################################################################################
# Config
###################################################################################################

# aFmt test points
aS_values = [0,1]
aI_values = np.arange(-3,1+3)
aF_values = np.arange(-3,1+3)

# shift test points
shift_values = np.arange(-2,1+2)

# rFmt test points
rS_values = [0,1]
rI_values = np.arange(-2,1+2)
rF_values = np.arange(-2,1+2)

# rnd test points
rnd_values = [FixRound.Trunc_s]

# sat test points
sat_values = [FixSaturate.None_s]

###################################################################################################
# Run
###################################################################################################

test_count = 0

test_aFmt = []
test_shift = []
test_rFmt = []
test_rnd = []
test_sat = []

########
# aFmt #
########
progress = ProgressReporter((aS_values, aI_values, aF_values))
for aS in aS_values:
    for aI in aI_values:
        for aF in aF_values:
            # Report progress
            progress.report()
            
            # Skip unusable formats
            if aS+aI+aF < 1:
                continue
            
            aFmt = FixFormat(aS, aI, aF)
            
            # Generate A data
            a = get_data(aFmt)
            
            for shift in shift_values:
                shiftFmt = FixFormat.ForShift(aFmt, shift)
                
                ########
                # rFmt #
                ########
                for rS in rS_values:
                    for rI in rI_values:
                        for rF in rF_values:
                            
                            # Skip unusable formats
                            if rS+rI+rF < 1:
                                continue
                            
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
                                    r = cl_fix_shift(a, aFmt, shift, rFmt, rnd, sat)
                                    
                                    # Save output to file
                                    np.savetxt(join(DATA_DIR, f"test{test_count}_output.txt"),
                                               cl_fix_to_integer(r, rFmt),
                                               fmt="%i", header=f"r[{r.size}]")
                                    
                                    # Save test parameters into lists
                                    test_aFmt.append(aFmt)
                                    test_shift.append(shift)
                                    test_rFmt.append(rFmt)
                                    test_rnd.append(rnd.value)
                                    test_sat.append(sat.value)
                                    
                                    test_count += 1

print(f"Cosim generated {test_count} tests.")

# Save formats
aFmt_names = ["aFmt" + str(i) for i in range(test_count)]
cl_fix_write_formats(test_aFmt, aFmt_names, join(DATA_DIR, f"aFmt.txt"))

rFmt_names = ["rFmt" + str(i) for i in range(test_count)]
cl_fix_write_formats(test_rFmt, rFmt_names, join(DATA_DIR, f"rFmt.txt"))

# Save shifts
np.savetxt(join(DATA_DIR, f"shift.txt"), test_shift, fmt="%i", header=f"Shifts")

# Save rounding and saturation modes
np.savetxt(join(DATA_DIR, f"rnd.txt"), test_rnd, fmt="%i", header=f"Rounding modes")
np.savetxt(join(DATA_DIR, f"sat.txt"), test_sat, fmt="%i", header=f"Saturation modes")
