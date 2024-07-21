###################################################################################################
# Copyright (c) 2024 Enclustra GmbH, Switzerland (info@enclustra.com)
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software
# and associated documentation files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
# BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
    
    # Note: Formats are tested exhaustively in the separate round/sat testbenches. Here, we use
    # a smaller test set to keep simulation times manageable.
    
    # a_fmt test points
    aS_values = [0, 1]
    aI_values = [-5, 0, 5]
    aF_values = [-5, 0, 5]

    # r_fmt test points
    rS_values = [0, 1]
    rI_values = [-5, 0, 5]
    rF_values = [-5, 0, 5]

    ###############################################################################################
    # Run
    ###############################################################################################

    test_count = 0

    test_a_fmt = []
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
                a_wide = WideFix.from_narrowfix(NarrowFix(a, a_fmt))
                
                #########
                # r_fmt #
                #########
                for rS in rS_values:
                    for rI in rI_values:
                        for rF in rF_values:
                            # Skip unusable formats
                            if rS+rI+rF < 1:
                                continue
                            
                            r_fmt = FixFormat(rS, rI, rF)
                            
                            ##########
                            # resize #
                            ##########
                            for rnd in FixRound:
                                for sat in FixSaturate:
                                    # Calculate output
                                    r = cl_fix_resize(a, a_fmt, r_fmt, rnd, sat)
                                    
                                    # Test WideFix input here, as there is no separate test script.
                                    # This is not actually part of the cosim data generation.
                                    r_wide = a_wide.resize(r_fmt, rnd, sat)
                                    assert np.array_equal(r_wide.to_real(), r)
                                    
                                    # Save output to file
                                    np.savetxt(join(DATA_DIR, f"test{test_count}_output.txt"),
                                               cl_fix_to_integer(r, r_fmt),
                                               fmt="%i", header=f"r[{r.size}]")
                                    
                                    # Save test parameters into lists
                                    test_a_fmt.append(a_fmt)
                                    test_r_fmt.append(r_fmt)
                                    test_rnd.append(rnd.value)
                                    test_sat.append(sat.value)
                                    
                                    test_count += 1

    print(f"Cosim generated {test_count} tests.")

    # Save formats
    a_fmt_names = ["a_fmt" + str(i) for i in range(test_count)]
    cl_fix_write_formats(test_a_fmt, a_fmt_names, join(DATA_DIR, f"a_fmt.txt"))

    r_fmt_names = ["r_fmt" + str(i) for i in range(test_count)]
    cl_fix_write_formats(test_r_fmt, r_fmt_names, join(DATA_DIR, f"r_fmt.txt"))

    # Save rounding and saturation modes
    np.savetxt(join(DATA_DIR, f"rnd.txt"), test_rnd, fmt="%i", header=f"Rounding modes")
    np.savetxt(join(DATA_DIR, f"sat.txt"), test_sat, fmt="%i", header=f"Saturation modes")

###################################################################################################
# Support execution as a script
###################################################################################################
if __name__ == '__main__':
    run()