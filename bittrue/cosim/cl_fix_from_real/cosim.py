###################################################################################################
# Copyright (c) 2023 Enclustra GmbH, Switzerland (info@enclustra.com)
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

###################################################################################################
# Main
###################################################################################################
def run():
    # Clear data directory
    DATA_DIR = join(root, "data")
    clear_directory(DATA_DIR)

    ###############################################################################################
    # Config
    ###############################################################################################

    # aFmt test points
    aS_values = [0,1]
    aI_values = np.arange(-4,1+4)
    aF_values = np.arange(-4,1+4)

    # rFmt test points
    rS_values = [0,1]
    rI_values = np.arange(-4,1+4)
    rF_values = np.arange(-4,1+4)
    
    ###############################################################################################
    # Run
    ###############################################################################################

    test_count = 0

    test_aFmt = []
    test_rFmt = []
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
                a_wide = WideFix.FromFxp(a, aFmt)
                
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
                            # sat #
                            ####### Note: Saturation is mandatory in cl_fix_from_real()
                            for sat in (FixSaturate.SatWarn_s, FixSaturate.Sat_s):
                                
                                # Calculate output
                                r = cl_fix_from_real(a, rFmt, sat)
                                
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

###################################################################################################
# Support execution as a script
###################################################################################################
if __name__ == '__main__':
    run()