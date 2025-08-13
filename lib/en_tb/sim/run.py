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

#--------------------------------------------------------------------------------------------------
#-  Description:
#-
#-  VUnit run script.
#--------------------------------------------------------------------------------------------------

# Import Python modules
from os.path import join, dirname, abspath, realpath
import sys

import common
from common import VUnit, VUnitCLI
from cosim_runner import CosimRunner

def create_test_suite(vu, args):
    ROOT = dirname(realpath(__file__))

    # Add VUnit libraries
    vu.add_osvvm()
    vu.add_verification_components()
    vu.add_random()
    
    # Add en_tb library
    en_tb = vu.add_library("en_tb")
    en_tb.add_source_files(join(ROOT, "../hdl/*.vhd"), vhdl_standard=common.vhdl_standard_tb)
    
    # Add testbench library
    lib = vu.add_library("lib")
    lib.add_source_files(join(ROOT, "../tb/*.vhd"), vhdl_standard=common.vhdl_standard_tb)
    
    ###############################################################################################
    # Cosim Runner
    ###############################################################################################
    
    # Specify path to cosim scripts
    COSIM_PATH = join(ROOT, "../bittrue/cosim/")
    
    # Specialize the "common" cosim runner to execute scripts at COSIM_PATH/<dirname>/cosim.py
    class Cosim(CosimRunner):
        def __init__(self, dirname):
            super().__init__(disable=args.disable_cosim, cosim_path=join(COSIM_PATH, dirname))
    
    ###############################################################################################
    # Testbench Configurations
    ###############################################################################################
    
    # en_tb_fileio
    en_tb_fileio_cosim = Cosim("en_tb_fileio")
    en_tb_fileio_tb = lib.test_bench("en_tb_fileio_tb")
    
    # Get number of tests defined in cosim.py.
    n_tests = en_tb_fileio_cosim.get_config()["N_TESTS"]
    
    test = en_tb_fileio_tb.get_tests("test")[0]
    for i in range(n_tests):
        name = f"TestIndex={i}"
        generics = dict(test_index_g=i)
        test.add_config(name=name, generics=generics, pre_config=en_tb_fileio_cosim.run)
    
    ###############################################################################################
    # Compile and simulation options
    ###############################################################################################
    lib.set_compile_option("modelsim.vcom_flags", ["+cover=sbceft", "-check_synthesis", "-suppress", "143"])
    lib.set_compile_option("modelsim.vlog_flags", ["+cover=sbceft"])
    lib.set_compile_option("ghdl.a_flags", ["-frelaxed"])
    lib.set_sim_option("ghdl.elab_flags", ["-frelaxed"])
    lib.set_sim_option("ghdl.sim_flags", ["--max-stack-alloc=0"])
    if args.simulator == 'questa' and args.gui == False:
        lib.set_sim_option("modelsim.three_step_flow", True)
    lib.set_sim_option("disable_ieee_warnings", True)
    if args.coverage:
        lib.set_sim_option("enable_coverage", True)


# Call VUnit main
if __name__== "__main__":

    # Initialize VUnit and get custom arguments
    args = common.args

    # Create VUnit object from command line arguments
    vu = VUnit.from_args(args=args)
    vu.add_vhdl_builtins()
    
    # Create test suite
    create_test_suite(vu, args)

    # Call VUnit main
    vu.main(post_run=common.post_run)
