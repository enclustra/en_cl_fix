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
from os.path import join, dirname, abspath
import sys

root = abspath(dirname(__file__))

import common
from common import VUnit, VUnitCLI, vhdl_standard_rtl, vhdl_standard_tb
from cosim_runner import cosim_runner

def create_test_suite(vu, args):
    # Add VUnit libraries
    vu.add_osvvm()
    vu.add_verification_components()
    vu.add_random()
    
    # Add en_tb library
    try:
        en_tb = vu.add_library("en_tb")
        en_tb.add_source_files(join(root, "../lib/en_tb/hdl/*.vhd"), vhdl_standard=vhdl_standard_tb)
    except ValueError:
        print("en_tb already created, skip it...")
    
    # Create testbench library
    lib = vu.add_library("lib")
    # Add RTL files
    lib.add_source_files(join(root, "../hdl/*.vhd"), vhdl_standard=vhdl_standard_rtl)
    # Add en_cl_fix extensions to en_tb
    lib.add_source_files(join(root, "../tb/util/*.vhd"), vhdl_standard=vhdl_standard_tb)
    # Add testbench files
    lib.add_source_files(join(root, "../tb/*.vhd"), vhdl_standard=vhdl_standard_tb)
    
    ###############################################################################################
    # Add testbench run configurations
    ###############################################################################################
    
    # Specify path to cosim scripts
    COSIM_PATH = join(root, "../bittrue/cosim")
    
    # Specialize the "common" cosim runner to run specific cosim scripts
    class cosim(cosim_runner):
        def __init__(self, dirname):
            cosim_subdir = join(COSIM_PATH, dirname)
            super().__init__(args.disable_cosim, cosim_subdir)
    
    ##############
    # cl_fix_add #
    ##############
    cl_fix_add_cosim = cosim("cl_fix_add")
    cl_fix_add_tb = lib.test_bench("cl_fix_add_tb")
    
    for test in cl_fix_add_tb.get_tests("test"):
        test.add_config(name=f"Test",
                        generics=dict(),
                        pre_config=cl_fix_add_cosim.run)
    
    ##############
    # cl_fix_sub #
    ##############
    cl_fix_sub_cosim = cosim("cl_fix_sub")
    cl_fix_sub_tb = lib.test_bench("cl_fix_sub_tb")
    
    for test in cl_fix_sub_tb.get_tests("test"):
        test.add_config(name=f"Test",
                        generics=dict(),
                        pre_config=cl_fix_sub_cosim.run)
    
    #################
    # cl_fix_addsub #
    #################
    cl_fix_addsub_cosim = cosim("cl_fix_addsub")
    cl_fix_addsub_tb = lib.test_bench("cl_fix_addsub_tb")
    
    for test in cl_fix_addsub_tb.get_tests("test"):
        test.add_config(name=f"Test",
                        generics=dict(),
                        pre_config=cl_fix_addsub_cosim.run)
    
    ###############
    # cl_fix_mult #
    ###############
    cl_fix_mult_cosim = cosim("cl_fix_mult")
    cl_fix_mult_tb = lib.test_bench("cl_fix_mult_tb")
    
    for test in cl_fix_mult_tb.get_tests("test"):
        test.add_config(name=f"Test",
                        generics=dict(),
                        pre_config=cl_fix_mult_cosim.run)
    
    ##############
    # cl_fix_neg #
    ##############
    cl_fix_neg_cosim = cosim("cl_fix_neg")
    cl_fix_neg_tb = lib.test_bench("cl_fix_neg_tb")
    
    for test in cl_fix_neg_tb.get_tests("test"):
        test.add_config(name=f"Test",
                        generics=dict(),
                        pre_config=cl_fix_neg_cosim.run)
    
    ##############
    # cl_fix_abs #
    ##############
    cl_fix_abs_cosim = cosim("cl_fix_abs")
    cl_fix_abs_tb = lib.test_bench("cl_fix_abs_tb")
    
    for test in cl_fix_abs_tb.get_tests("test"):
        test.add_config(name=f"Test",
                        generics=dict(),
                        pre_config=cl_fix_abs_cosim.run)
    
    ################
    # cl_fix_shift #
    ################
    cl_fix_shift_cosim = cosim("cl_fix_shift")
    cl_fix_shift_tb = lib.test_bench("cl_fix_shift_tb")
    
    for test in cl_fix_shift_tb.get_tests("test"):
        test.add_config(name=f"Test",
                        generics=dict(),
                        pre_config=cl_fix_shift_cosim.run)
    
    ##################
    # cl_fix_compare #
    ##################
    cl_fix_compare_cosim = cosim("cl_fix_compare")
    cl_fix_compare_tb = lib.test_bench("cl_fix_compare_tb")
    
    for test in cl_fix_compare_tb.get_tests("test"):
        test.add_config(name=f"Test",
                        generics=dict(),
                        pre_config=cl_fix_compare_cosim.run)
    
    ################
    # cl_fix_round #
    ################
    cl_fix_round_cosim = cosim("cl_fix_round")
    cl_fix_round_tb = lib.test_bench("cl_fix_round_tb")
    
    test = cl_fix_round_tb.get_tests("test")[0]
    for meta_width in [0, 8]:
        name = f"MetaWidth={meta_width}"
        generics = dict(meta_width_g=meta_width)
        test.add_config(name=name,
                        generics=generics,
                        pre_config=cl_fix_round_cosim.run)
    
    ###################
    # cl_fix_saturate #
    ###################
    cl_fix_saturate_cosim = cosim("cl_fix_saturate")
    cl_fix_saturate_tb = lib.test_bench("cl_fix_saturate_tb")
    
    test = cl_fix_saturate_tb.get_tests("test")[0]
    for meta_width in [0, 8]:
        name = f"MetaWidth={meta_width}"
        generics = dict(meta_width_g=meta_width)
        test.add_config(name=name,
                        generics=generics,
                        pre_config=cl_fix_saturate_cosim.run)
    
    #################
    # cl_fix_resize #
    #################
    cl_fix_resize_cosim = cosim("cl_fix_resize")
    cl_fix_resize_tb = lib.test_bench("cl_fix_resize_tb")
    
    test = cl_fix_resize_tb.get_tests("test")[0]
    for meta_width in [0, 8]:
        name = f"MetaWidth={meta_width}"
        generics = dict(meta_width_g=meta_width)
        test.add_config(name=name,
                        generics=generics,
                        pre_config=cl_fix_resize_cosim.run)
    
    ####################
    # cl_fix_from_real #
    ####################
    cl_fix_from_real_cosim = cosim("cl_fix_from_real")
    cl_fix_from_real_tb = lib.test_bench("cl_fix_from_real_tb")
    
    for test in cl_fix_from_real_tb.get_tests("test"):
        test.add_config(name=f"Test",
                        generics=dict(),
                        pre_config=cl_fix_from_real_cosim.run)
    
    ###############################################################################################
    # Set compile and simulation options
    ###############################################################################################

    # Set compile and simulation options for GHDL
    vu.add_compile_option("ghdl.a_flags", ["--warn-no-hide"])
    lib.set_compile_option("ghdl.a_flags", ["-frelaxed", "--warn-no-hide", "--warn-no-specs"])
    lib.set_sim_option("ghdl.elab_flags", ["-frelaxed"])
    lib.set_sim_option("ghdl.sim_flags", ["--max-stack-alloc=0"])

    # Set compile and simulation options for NVC
    vu.add_compile_option("nvc.a_flags", ["--relaxed", "--check-synthesis"])
    lib.set_sim_option("nvc.global_flags", ["-M 8192m"])
    lib.set_sim_option("nvc.heap_size", "8192m")

    # Set compile and simulation options for Modelsim and Questa
    lib.set_compile_option("modelsim.vcom_flags", ["+cover=sbceft", "-check_synthesis", "-coverdeglitch", "0", "-suppress", "143"])
    lib.set_compile_option("modelsim.vlog_flags", ["+cover=sbceft"])
    lib.set_sim_option("modelsim.vsim_flags", ["-t 1ps", "-voptargs=+acc"])
    if args.simulator == 'questa' and args.gui == False:
        lib.set_sim_option("modelsim.three_step_flow", True)

    # Set compile and simulation options for all simulators
    lib.set_sim_option("disable_ieee_warnings", True)
    if args.coverage:
        lib.set_sim_option("enable_coverage", True)

    # Add waveform automatically when running in GUI mode.
    for tb in lib.get_test_benches():
        tb.set_sim_option("modelsim.init_file.gui", join(root, "scripts/" + tb.name + "_wave.do"))
        tb.set_sim_option("ghdl.viewer_script.gui", join(root, "scripts/" + tb.name + "_wave.cmd"))
        tb.set_sim_option("nvc.viewer_script.gui", join(root, "scripts/" + tb.name + "_wave.cmd"))

if __name__ == '__main__':

    # Initialize VUnit and get custom arguments
    args = common.args

    # Create VUnit object from command line arguments
    vu = VUnit.from_args(args=args)
    vu.add_vhdl_builtins()

    # Create test suite
    create_test_suite(vu, args)

    # Call VUnit main
    vu.main(post_run=common.post_run)
