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
from os import environ, system, getcwd, chdir

# Import VUnit
import sys
sys.path.insert(1, abspath(dirname(__file__)) + "/../../lib/FW/VHDL/vunit")
from vunit import VUnitCLI, VUnit

# Add custom command line arguments
cli = VUnitCLI()
cli.parser.add_argument(
        "--simulator",
        default=environ["EN_SIM_NAME"] if "EN_SIM_NAME" in environ else None,
        help="Define simulator to be used: name (allowed values: modelsim, questa, nvc or ghdl)",
    )
cli.parser.add_argument(
        "-s",
        "--simulator-path",
        default=environ["EN_SIM_BIN"] if "EN_SIM_BIN" in environ else None,
        help="Define simulator to be used: path to the simulator binary location",
    )
cli.parser.add_argument(
        "--vendor-lib",
        default=environ["EN_SIM_LIB"] if "EN_SIM_LIB" in environ else None,
        help="Set vendor precompiled simulation library location",
    )
cli.parser.add_argument(
        "-c",
        "--coverage",
        action="store_true",
        default=False,
        help="Enables simulation coverage",
    )
cli.parser.add_argument(
        "--disable-cosim",
        action="store_true",
        default=False,
        help="Disables automatic execution of cosim scripts",
    )

# Parse command line arguments
args = cli.parse_args()

# Check arguments
if args.simulator == None:
    raise Exception("\n\nERROR: please use --simulator <name> to define the simulator. Allowed values: modelsim, questa, nvc or ghdl. E.g: python run.py --simulator modelsim\n")
if args.simulator_path == None:
    raise Exception("\n\nERROR: please use --simulator-path <path> to define the simulator path. E.g.: python run.py --simulator-path E:/modeltech_pe_2020.1/win32pe\n")

# Set VUnit environment variables
if args.simulator == 'questa':
    # VUnit supports questa (vsim) but does not support the name 'questa' as a valid simulator name yet.
    # The workaround is to use the name 'modelsim' but still provide the questa install folder.
    environ["VUNIT_SIMULATOR"] = 'modelsim'
else:
    environ["VUNIT_SIMULATOR"] = args.simulator
environ["VUNIT_MODELSIM_PATH"] = args.simulator_path
environ["VUNIT_GHDL_PATH"] = args.simulator_path
environ["VUNIT_NVC_PATH"] = args.simulator_path

# Set VHDL standard according to the simulators
if args.simulator == 'modelsim' or args.simulator == 'questa':
    vhdl_standard_rtl = "93"
    vhdl_standard_tb  = "2008"
elif args.simulator == 'ghdl' or args.simulator == 'nvc':
    vhdl_standard_rtl = "2008"
    vhdl_standard_tb  = "2008"
else:
    raise Exception("\n\nERROR: please use --simulator <name> to define the simulator. Allowed values: modelsim, questa, nvc or ghdl. E.g: python run.py --simulator modelsim\n")

# Callback function which is called after running tests (merge coverage data)
def post_run(results):
    if args.coverage:
        if args.simulator in ['questa', 'modelsim']:
            root = dirname(__file__)
            coverage_data = join(root, 'coverage/coverage_data.ucdb')
            coverage_do = join(root, 'coverage/coverage.do')
            cwd = getcwd()
            chdir(root)
            results.merge_coverage(file_name=coverage_data)
            print('generating coverage report file...')
            system('%s/vsim -c -viewcov %s -do %s' % (environ['VUNIT_MODELSIM_PATH'], coverage_data, coverage_do))
            print('done creating coverage report file.')
            chdir(cwd)
        elif args.simulator == 'nvc':
            print("----------------------------------------------------------")
            print("Warning: Coverage support with 'nvc' is not yet supported.")
            print("----------------------------------------------------------")