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

# Import Python modules
import sys
from threading import Lock
import runpy

# This global threadlock ensures only one cosim script is added to the system path (and executed)
# at a time. This allows multiple cosim scripts to have the same filename (e.g. cosim.py).
COSIM_PATH_THREADLOCK = Lock()

# Cosim runner class to: (1) Run the cosim script at most once (thread safe) and (2) Give access to
# any config info needed to enumerate all test cases in run.py (e.g. number of test sets defined).
class cosim_runner:
    def __init__(self, disable, cosim_path, module_name="cosim"):
        self.enable = not disable
        self.cosim_path = cosim_path
        self.module_name = module_name
        # Local threadlock to guarantee at most 1 execution of the cosim when multi-threading.
        self.lock = Lock()
        
        # Run the cosim module to get its module globals dictionary.
        # Note: This does *NOT* execute the cosimulation run() function.
        # Note: To support multiple cosim scripts with the same name (e.g. cosim.py), we only
        # modify the system path temporarily, then revert it. A global threadlock is used to do
        # this in a thread-safe way.
        with COSIM_PATH_THREADLOCK:
            # Note: Using insert() instead of append should avoid issues with module name clashes.
            sys.path.insert(1, self.cosim_path)
            self.module_dict = runpy.run_module(self.module_name)
            sys.path.remove(self.cosim_path)
    
    # Get config needed for enumerating all test cases in run.py (*without* running the cosim).
    def get_config(self):
        # Get the COSIM_CONFIG object to return (if one exists)
        try:
            retval = self.module_dict['COSIM_CONFIG']
        except AttributeError:
            retval = None
        return retval
    
    # Callback function to pass to VUnit pre_config
    def run(self):
        # First enable check: To avoid waiting on the threadlock when disabled.
        if self.enable:
            with self.lock:
                # Second enable check: In case we had to wait on the threadlock (so in the meantime
                # another thread executed the cosim and set self.enable = false).
                if self.enable:
                    # Execute the cosimulation run() function
                    self.module_dict["run"]()
                    # Self-disable to prevent multiple cosim executions
                    self.enable = False
        # Must return true to tell VUnit run was successful
        return True
