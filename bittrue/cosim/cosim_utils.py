import sys
import os
from os.path import join, dirname
from shutil import rmtree
import numpy as np

sys.path.append(join(dirname(__file__), "../models/python"))
from en_cl_fix_pkg import *

###################################################################################################
# Helper Functions
###################################################################################################

def clear_directory(path):
    try:
        rmtree(path)
    except FileNotFoundError:
        pass
    os.mkdir(path)

def get_data(fmt : FixFormat):
    # Generate every possible value in format (counter)
    int_min = cl_fix_to_integer(cl_fix_min_value(fmt), fmt)
    int_max = cl_fix_to_integer(cl_fix_max_value(fmt), fmt)
    int_data = np.arange(int_min, 1+int_max)
    return cl_fix_from_integer(int_data, fmt)

def repeat_each_value(x, n):
    return np.tile(x, (n,1)).flatten(order='F')

def repeat_whole_array(x, n):
    return np.tile(x, (n,1)).flatten(order='C')

###################################################################################################
# Progress Reporter Class
###################################################################################################

# Helper class for printing progress %
class ProgressReporter:
    def __init__(self, param_lists, message="Generating cosim data"):
        param_counts = [len(param_list) for param_list in param_lists]
        self._total_params = np.prod(param_counts)
        self.message = message
        self.step_percent = 10 # Print progress after each 10%
        self._next_percent = 0
        self._index = 0
        
    def report(self):
        # Print start message
        if self._index == 0:
            print(self.message + ": ", end="", flush=True)
        
        # Update % completion
        self._index += 1
        percent = 100 * self._index / self._total_params
        
        # Print progress
        if percent >= self._next_percent:
            print(f"{int(self._next_percent)}%...", end="", flush=True)
            self._next_percent += self.step_percent
        
        # Print finish message
        if self._index == self._total_params:
            print("Done.", flush=True)
    