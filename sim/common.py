###################################################################################################
# Copyright (c) 2022 Enclustra GmbH, Switzerland (info@enclustra.com)
###################################################################################################

# Import Python modules
from os.path import join, dirname, abspath
from os import environ, system, getcwd, chdir
import subprocess
from threading import Lock

# Import VUnit
try:
    import sys
    sys.path.append(join(abspath(dirname(__file__)), "../../vunit"))
    import VUnitCLI, VUnit
except ImportError as e:
    from vunit import VUnitCLI, VUnit

# Helper class to run cosim script at most once (thread safe)
class cosim_runner:
    def __init__(self, disable, target):
        self.enable = not disable
        self.target = target
        # Thread lock for ensuring thread safety when executing VUnit in parallel (-p)
        self.lock = Lock()
    
    # Callback function to pass to VUnit pre_config
    def run(self):
        # Lock thread to ensure thread safety when executing VUnit in parallel (-p)
        with self.lock:
            if self.enable:
                # Launch Python in a new process and exectute cosim script
                status = subprocess.run(["python3", self.target])
                # Check returncode and report any error
                if status.returncode != 0:
                    print(f"ERROR! Cosim script execution failed: {self.target}")
                    return False
                self.enable = False
        # Must return true to tell VUnit run was successful
        return True

# Add custom command line arguments
cli = VUnitCLI()
cli.parser.add_argument(
        "--simulator",
        default=environ["EN_SIM_NAME"] if "EN_SIM_NAME" in environ else None,
        help="Define simulator to be used: name (allowed values: modelsim, questa or ghdl)",
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
    "--vivado-dir",
    default=environ["EN_VIVADO_BIN"] if "EN_VIVADO_BIN" in environ else None,
    help="Path to the Vivado install folder",
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
    raise Exception("\n\nERROR: please use --simulator <name> to define the simulator. Allowed values: modelsim or ghdl. E.g: python run.py --simulator modelsim\n")
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

# Set VHDL standard according to the simulators
if args.simulator == 'modelsim' or args.simulator == 'questa':
    vhdl_standard_rtl = "93"
    vhdl_standard_tb  = "2008"
elif args.simulator == 'ghdl':
    vhdl_standard_rtl = "2008"
    vhdl_standard_tb  = "2008"
else:
    raise Exception("\n\nERROR: please use --simulator <name> to define the simulator. Allowed values: modelsim, questa or ghdl. E.g: python run.py --simulator modelsim\n")

# Callback function which is called after running tests (merge coverage data)
def post_run(results):
    if args.coverage:
        root = dirname(__file__)
        coverage_data = join(root, "coverage/coverage_data.ucdb")
        coverage_do = join(root, "coverage/coverage.do")
        cwd = getcwd()
        chdir(root)
        results.merge_coverage(file_name=coverage_data)
        print("generating coverage report file...")
        system('%s/vsim -c -viewcov %s -do %s' % (environ["VUNIT_MODELSIM_PATH"], coverage_data, coverage_do))
        print("done creating coverage report file.")
        chdir(cwd)