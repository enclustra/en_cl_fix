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
# Description:
#
# This script checks the data conversions needed for interfacing with MATLAB.
###################################################################################################

###################################################################################################
# Imports
###################################################################################################
import sys
from os.path import join, dirname
root = dirname(__file__)
sys.path.append(join(root, "../../models/python"))
from en_cl_fix_pkg import *

import numpy as np

# Make results repeatable
random.seed(0)
np.random.seed(0)

BIT_WIDTHS = [60, 65, 151]
ARRAY_DIMS = np.arange(1, 1+5)
MAX_DIM_LENGTH = 20
TRIALS = 10

for trial in range(TRIALS):
    print("=====================================")
    print(f"Starting random trial {1+trial} of {TRIALS}...")
    for bit_width in BIT_WIDTHS:
        # Define a random fixed-point format
        S = np.random.randint(low=0, high=1+1)
        I = np.random.randint(low=-2*bit_width, high=1+2*bit_width)
        F = bit_width - S - I
        fmt = FixFormat(S, I, F)
        
        print(f"    Format = {fmt}")
        
        for array_dims in ARRAY_DIMS:
            # Define a random array shape
            shape = np.random.randint(low=1, high=1+MAX_DIM_LENGTH, size=array_dims)
            
            print(f"        Data array shape = {shape}")
            
            # Generate random data values
            in_data = cl_fix_random(shape, fmt)
            
            # Pack into uint64 (e.g. for passing data to MATLAB)
            packed = to_uint64_array(in_data.copy(), fmt)
            
            # Unpack from uint64 (e.g. for receiving data from MATLAB)
            unpacked = from_uint64_array(packed.copy(), fmt)
            
            # Check
            assert np.array_equal(in_data, unpacked)
        
print("\nSuccess: All tests passed.")

