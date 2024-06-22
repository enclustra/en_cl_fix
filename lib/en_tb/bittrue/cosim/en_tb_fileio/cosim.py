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
# Co-simulation script for en_tb file I/O.
#
###################################################################################################
import sys
import os
from os.path import dirname, abspath, join
from shutil import rmtree
import numpy as np
import random

ROOT = dirname(abspath(__file__))

###################################################################################################
# Test Definitions
###################################################################################################

# Define parameter sets.
DATA_WIDTHS = [32, 53, 120]
FILE_COLUMNS = [1, 3]

###################################################################################################
# Parameters visible to run.py
###################################################################################################

# Define here any parameters that run.py requires to *enumerate* all test cases.
# If no parameters are required by run.py, then delete this section.

# Number of test cases.
N_TESTS = len(DATA_WIDTHS) * len(FILE_COLUMNS)

# Dictionary to pass to run.py
COSIM_CONFIG = {}
COSIM_CONFIG["N_TESTS"] = N_TESTS

###################################################################################################
# Main
###################################################################################################
def run():
    """
    Generates all cosim data and saves it to file.
    """
    
    # Make results repeatable
    random.seed(0)
    np.random.seed(0)
    
    # Data directory
    DATA_DIR = join(ROOT, "data")
    try:
        rmtree(DATA_DIR)
    except FileNotFoundError:
        pass
    os.mkdir(DATA_DIR)
    
    # Util function
    def randi(shape, min_val, max_val):
        """
        Returns an np.ndarray of random (arbitrary-precision) int objects.
        
        shape:      Shape of the returned array.
        min_val:    Minimum returned value (inclusive).
        max_val:    Maximum returned value (inclusive).
        """
        n = np.prod(shape)
        x = np.empty((n,), dtype=object)
        for i in range(n):
            x[i] = random.randrange(min_val, max_val+1)
        
        return x.reshape(shape)
    
    def to_unsigned(data, width):
        """
        Returns the width-bit signed input data, reinterpeted as width-bit unsigned.
        """
        return np.where(data < 0, data + 2**width, data)
    
    def savetxt_binary(filename, data, data_width, header):
        """
        Similar to np.savetxt, except it writes binary data.
        Numpy does not support the 'b' designator:
        https://stackoverflow.com/questions/66449496/how-does-one-get-savetxt-numpy-to-run-using-b-as-my-format-designator
        """
        with open(filename, "w") as f:
            # Write header
            f.write("# " + header + "\n")
            
            # Write data
            vals_per_row = 1 if len(data.shape) < 2 else data.shape[1]
            fmt = '{:0' + str(data_width) + 'b}'
            for row in data:
                for j in range(vals_per_row):
                    space = " " if j < vals_per_row-1 else ""
                    f.write(fmt.format(row[j]) + space)
                f.write("\n")
            
    
    N_DATA = 256
    i = 0
    for file_columns in FILE_COLUMNS:
        for data_width in DATA_WIDTHS:
            # Signed extreme values
            smin = -2**(data_width-1)
            smax = 2**(data_width-1) - 1
            
            # Unsigned extreme values
            umin = 0
            umax = 2**data_width-1
            
            # Generate random signed data
            data_signed = randi((N_DATA, file_columns), smin, smax)
            # Overwrite the first 2 values with signed extremes (worst cases)
            data_signed[0] = smin
            data_signed[1] = smax
            
            # Generate random unsigned data
            data_unsigned = randi((N_DATA, file_columns), umin, umax)
            # Overwrite the first 2 values with unsigned extremes (worst cases)
            data_unsigned[0] = umin
            data_unsigned[1] = umax
            
            #######################################################################################
            # Write Files
            #######################################################################################
            
            # Config
            np.savetxt(join(DATA_DIR, f"test{i}_config.txt"), [data_width, file_columns], fmt="%i", header=f"data_width, file_columns")
            
            # Binary data
            # IMPORTANT: savetxt_binary supports *signed* bin (i.e. with a "-" sign). However, the
            # VHDL READ procedures expect two's complement. Therefore, we must reinterpret as
            # unsigned before saving.
            savetxt_binary(join(DATA_DIR, f"test{i}_ascii_bin_data_signed.txt"), to_unsigned(data_signed, data_width), data_width, header=f"Data (signed)")
            savetxt_binary(join(DATA_DIR, f"test{i}_ascii_bin_data_unsigned.txt"), data_unsigned, data_width, header=f"Data (unsigned)")
            
            # Decimal data
            np.savetxt(join(DATA_DIR, f"test{i}_ascii_dec_data_signed.txt"), data_signed, fmt="%i", header=f"Data (signed)")
            np.savetxt(join(DATA_DIR, f"test{i}_ascii_dec_data_unsigned.txt"), data_unsigned, fmt="%i", header=f"Data (unsigned)")
            
            # Hex data
            # IMPORTANT: numpy's savetxt supports *signed* hex (i.e. with a "-" sign). However, the
            # VHDL HREAD procedures expect two's complement. Therefore, we must reinterpret as
            # unsigned before saving.
            n_hex = (data_width + 3)//4
            np.savetxt(join(DATA_DIR, f"test{i}_ascii_hex_data_signed.txt"), to_unsigned(data_signed, data_width), fmt=f"%0{n_hex}x", header=f"Data (signed)")
            np.savetxt(join(DATA_DIR, f"test{i}_ascii_hex_data_unsigned.txt"), data_unsigned, fmt=f"%0{n_hex}x", header=f"Data (unsigned)")
            
            # Increment test index
            i += 1
    
    assert i == N_TESTS, f"Expected {N_TESTS} tests, but only counted {i}."
    
###################################################################################################
# Support execution as a script
###################################################################################################
if __name__ == '__main__':
    run()
