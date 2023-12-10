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
    aI_values = np.arange(-3,1+3)
    aF_values = np.arange(-3,1+3)

    # b_fmt test points
    bS_values = [0,1]
    bI_values = np.arange(-3,1+3)
    bF_values = np.arange(-3,1+3)

    ###############################################################################################
    # Run
    ###############################################################################################

    test_count = 0

    test_a_fmt = []
    test_b_fmt = []
    test_r_fmt = []
    test_rnd = []
    test_sat = []

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
                
                #########
                # b_fmt #
                #########
                for bS in bS_values:
                    for bI in bI_values:
                        for bF in bF_values:
                            # Skip formats with non-positive length
                            if bS+bI+bF <= 0:
                                continue
                            
                            b_fmt = FixFormat(bS, bI, bF)
                            
                            # Generate B data
                            b = get_data(b_fmt)
                            
                            # Produce all combinations of all a and b values
                            a_all = repeat_whole_array(a, len(b))
                            b_all = repeat_each_value(b, len(a))
                            a_wide = WideFix.from_narrowfix(NarrowFix(a_all, a_fmt))
                            b_wide = WideFix.from_narrowfix(NarrowFix(b_all, b_fmt))
                            
                            # Calculate outputs
                            r_eq = a_all == b_all
                            r_neq = a_all != b_all
                            r_less = a_all < b_all
                            r_greater = a_all > b_all
                            r_leq = a_all <= b_all
                            r_geq = a_all >= b_all
                            
                            # Test WideFix input here, as there is no separate test script.
                            # This is not actually part of the cosim data generation.
                            r_eq_wide = a_wide == b_wide
                            r_neq_wide = a_wide != b_wide
                            r_less_wide = a_wide < b_wide
                            r_greater_wide = a_wide > b_wide
                            r_leq_wide = a_wide <= b_wide
                            r_geq_wide = a_wide >= b_wide
                            assert np.array_equal(r_eq_wide, r_eq)
                            assert np.array_equal(r_neq_wide, r_neq)
                            assert np.array_equal(r_less_wide, r_less)
                            assert np.array_equal(r_greater_wide, r_greater)
                            assert np.array_equal(r_leq_wide, r_leq)
                            assert np.array_equal(r_geq_wide, r_geq)
                            
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
                            test_a_fmt.append(a_fmt)
                            test_b_fmt.append(b_fmt)
                            
                            test_count += 1

    # Save formats
    a_fmt_names = ["a_fmt" + str(i) for i in range(test_count)]
    cl_fix_write_formats(test_a_fmt, a_fmt_names, join(DATA_DIR, f"a_fmt.txt"))

    b_fmt_names = ["b_fmt" + str(i) for i in range(test_count)]
    cl_fix_write_formats(test_b_fmt, b_fmt_names, join(DATA_DIR, f"b_fmt.txt"))

###################################################################################################
# Support execution as a script
###################################################################################################
if __name__ == '__main__':
    run()