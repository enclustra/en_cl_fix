###################################################################################################
# Copyright (c) 2022 Enclustra GmbH, Switzerland (info@enclustra.com)
###################################################################################################

# Import Python modules
from os.path import join, dirname, abspath
import sys

root = abspath(dirname(__file__))

import common
from common import VUnit, VUnitCLI, vhdl_standard_rtl, vhdl_standard_tb

def create_test_suite(vu, args):
    # Add VUnit libraries
    vu.add_osvvm()
    vu.add_verification_components()
    vu.add_random()

    # Create library
    lib = vu.add_library("lib_en_cl_fix")
    
    # Add EN_TB files
    lib.add_source_files(join(root, "../../en_tb/hdl/en_tb_base_pkg.vhd"), vhdl_standard=vhdl_standard_tb)
    lib.add_source_files(join(root, "../../en_tb/hdl/en_tb_fileio*.vhd"), vhdl_standard=vhdl_standard_tb)
    lib.add_source_files(join(root, "../../en_tb/hdl/en_tb_fix_fileio*.vhd"), vhdl_standard=vhdl_standard_tb)
    
    # Add RTL files
    lib.add_source_files(join(root, "../hdl/*.vhd"), vhdl_standard=vhdl_standard_rtl)
    
    # Add testbench files
    lib.add_source_files(join(root, "../tb/*.vhd"), vhdl_standard=vhdl_standard_tb)

    ###############################################################################################
    # Add testbench run configurations
    ###############################################################################################
    
    # Specify path to cosim scripts
    COSIM_PATH = join(root, "../bittrue/cosim")
    
    # Specialize the "common" cosim runner to run specific cosim scripts
    class cosim(common.cosim_runner):
        def __init__(self, dirname):
            target = join(COSIM_PATH, dirname, "cosim.py")
            super().__init__(args.disable_cosim, target)
    
    ##############
    # cl_fix_add #
    ##############
    cl_fix_add_cosim = cosim("cl_fix_add")
    cl_fix_add_tb = lib.test_bench("cl_fix_add_tb")
    
    for test in cl_fix_add_tb.get_tests("test"):
        test.add_config(name=(f"Test"),
                        generics=dict(),
                        pre_config=cl_fix_add_cosim.run)
    
    ##############
    # cl_fix_sub #
    ##############
    cl_fix_sub_cosim = cosim("cl_fix_sub")
    cl_fix_sub_tb = lib.test_bench("cl_fix_sub_tb")
    
    for test in cl_fix_sub_tb.get_tests("test"):
        test.add_config(name=(f"Test"),
                        generics=dict(),
                        pre_config=cl_fix_sub_cosim.run)
    
    #################
    # cl_fix_addsub #
    #################
    cl_fix_addsub_cosim = cosim("cl_fix_addsub")
    cl_fix_addsub_tb = lib.test_bench("cl_fix_addsub_tb")
    
    for test in cl_fix_addsub_tb.get_tests("test"):
        test.add_config(name=(f"Test"),
                        generics=dict(),
                        pre_config=cl_fix_addsub_cosim.run)
    
    ###############
    # cl_fix_mult #
    ###############
    cl_fix_mult_cosim = cosim("cl_fix_mult")
    cl_fix_mult_tb = lib.test_bench("cl_fix_mult_tb")
    
    for test in cl_fix_mult_tb.get_tests("test"):
        test.add_config(name=(f"Test"),
                        generics=dict(),
                        pre_config=cl_fix_mult_cosim.run)
    
    ##############
    # cl_fix_neg #
    ##############
    cl_fix_neg_cosim = cosim("cl_fix_neg")
    cl_fix_neg_tb = lib.test_bench("cl_fix_neg_tb")
    
    for test in cl_fix_neg_tb.get_tests("test"):
        test.add_config(name=(f"Test"),
                        generics=dict(),
                        pre_config=cl_fix_neg_cosim.run)
    
    ##############
    # cl_fix_abs #
    ##############
    cl_fix_abs_cosim = cosim("cl_fix_abs")
    cl_fix_abs_tb = lib.test_bench("cl_fix_abs_tb")
    
    for test in cl_fix_abs_tb.get_tests("test"):
        test.add_config(name=(f"Test"),
                        generics=dict(),
                        pre_config=cl_fix_abs_cosim.run)
    
    ################
    # cl_fix_shift #
    ################
    cl_fix_shift_cosim = cosim("cl_fix_shift")
    cl_fix_shift_tb = lib.test_bench("cl_fix_shift_tb")
    
    for test in cl_fix_shift_tb.get_tests("test"):
        test.add_config(name=(f"Test"),
                        generics=dict(),
                        pre_config=cl_fix_shift_cosim.run)
    
    ##################
    # cl_fix_compare #
    ##################
    cl_fix_compare_cosim = cosim("cl_fix_compare")
    cl_fix_compare_tb = lib.test_bench("cl_fix_compare_tb")
    
    for test in cl_fix_compare_tb.get_tests("test"):
        test.add_config(name=(f"Test"),
                        generics=dict(),
                        pre_config=cl_fix_compare_cosim.run)
    
    ################
    # cl_fix_round #
    ################
    cl_fix_round_cosim = cosim("cl_fix_round")
    cl_fix_round_tb = lib.test_bench("cl_fix_round_tb")
    
    for test in cl_fix_round_tb.get_tests("test"):
        test.add_config(name=(f"Test"),
                        generics=dict(),
                        pre_config=cl_fix_round_cosim.run)
    
    ###############################################################################################
    # Set compile and simulation options
    ###############################################################################################

    # Set compile and simulation options
    lib.set_compile_option("modelsim.vcom_flags", ["+cover=sbceft", "-check_synthesis", "-suppress", "143,14408"])
    lib.set_compile_option("modelsim.vlog_flags", ["+cover=sbceft"])
    lib.set_sim_option("modelsim.vsim_flags", ["-t 1ps", "-voptargs=+acc"])
    lib.set_sim_option("disable_ieee_warnings", True)
    if args.coverage:
        lib.set_sim_option("enable_coverage", True)

    # Add waveform automatically when running in GUI mode.
    for tb in lib.get_test_benches():
        tb.set_sim_option("modelsim.init_file.gui", join(root, "scripts/" + tb.name + "_wave.do"))

if __name__ == '__main__':

    # Initialize VUnit and get custom arguments
    args = common.args

    # Create VUnit object from command line arguments
    vu = VUnit.from_args(args=args)

    # Create test suite
    create_test_suite(vu, args)

    # Call VUnit main
    vu.main(post_run=common.post_run)
