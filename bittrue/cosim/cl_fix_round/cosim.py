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

    # a_fmt test points
    aS_values = [0,1]
    aI_values = np.arange(-5,1+5)
    aF_values = np.arange(-5,1+5)

    # r_fmt test points
    rF_values = np.arange(-5,1+5)

    ###############################################################################################
    # Run
    ###############################################################################################

    test_count = 0

    test_aFmt = []
    test_rFmt = []
    test_rnd = []

    #########
    # a_fmt #
    #########
    progress = ProgressReporter((aS_values, aI_values, aF_values))
    for aS in aS_values:
        for aI in aI_values:
            for aF in aF_values:
                # Report progress
                progress.report()
                
                # Skip unusable formats
                if aS+aI+aF < 1:
                    continue
                
                a_fmt = FixFormat(aS, aI, aF)
                
                # Generate A data
                a = get_data(a_fmt)
                a_wide = WideFix.from_narrowfix(NarrowFix(a, a_fmt))
                
                #########
                # r_fmt #
                #########
                for rF in rF_values:
                    #######
                    # rnd #
                    #######
                    for rnd in FixRound:
                        r_fmt = FixFormat.ForRound(a_fmt, rF, rnd)
                        
                        # Calculate output
                        r = cl_fix_round(a, a_fmt, r_fmt, rnd)
                        
                        # Test WideFix input here, as there is no separate test script.
                        # This is not actually part of the cosim data generation.
                        r_wide = a_wide.round(r_fmt, rnd)
                        assert np.array_equal(r_wide.to_real(), r)
                        
                        # Save output to file
                        np.savetxt(join(DATA_DIR, f"test{test_count}_output.txt"),
                                   cl_fix_to_integer(r, r_fmt),
                                   fmt="%i", header=f"r[{r.size}]")
                        
                        # Save test parameters into lists
                        test_aFmt.append(a_fmt)
                        test_rFmt.append(r_fmt)
                        test_rnd.append(rnd.value)
                        
                        test_count += 1

    print(f"Cosim generated {test_count} tests.")

    # Save formats
    a_fmt_names = ["a_fmt" + str(i) for i in range(test_count)]
    cl_fix_write_formats(test_aFmt, a_fmt_names, join(DATA_DIR, f"a_fmt.txt"))

    r_fmt_names = ["r_fmt" + str(i) for i in range(test_count)]
    cl_fix_write_formats(test_rFmt, r_fmt_names, join(DATA_DIR, f"r_fmt.txt"))

    # Save rounding and saturation modes
    np.savetxt(join(DATA_DIR, f"rnd.txt"), test_rnd, fmt="%i", header=f"Rounding modes")

###################################################################################################
# Support execution as a script
###################################################################################################
if __name__ == '__main__':
    run()