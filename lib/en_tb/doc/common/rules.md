# Checklist for Adding New HDL Files

Library code has higher quality requirements than ordinary project code. Code reuse must be taken into consideration when defining package interfaces. These should be tidy and simple to understand.

Use one .vhd file per package (except for instances of generic packages).

If the following requirements cannot be met, then the code is not ready to be added to this library.

## Components

Do not add any VHDL entities to this library, unless a new use case is agreed with the library maintainer (and stated here).

Reusable simulation entities are expected to be VUnit models, which belong in [en_vunit](https://gitlab.enclustra.com/Enclustra/Lib/Fw/VHDL/en_vunit).

## Packages

All package names shall be of the form _en\_tb\_\*\_pkg_:
+ Add hdl/en_tb\__\*_\_pkg.vhd
    + Ensure Copyright header is present. Delete any other legacy header fields.
    + Ensure link to doc page is included beneath header (for easy navigation).
    + Ensure functions/procedures are well commented. The level of detail must be sufficient that another developer can understand and use them.
+ Add tb/en_tb\__\*_\_pkg/en_tb\__\*_\_tb.vhd and run.py
+ Add doc/en_tb\__\*_\_pkg/readme.md
    + In many cases, a short summary, followed by a link to the VHDL source file is sufficient.
    + (If necessary) add any extra detail that may be helpful.
    + Add a link to testbench files.
+ Update index.md with a link to doc/en_tb\__\*_\_pkg.

# Testbenches and Simulation

Each package (or VHDL-2008 *context* comprising multiple packages) shall have at least a simple unit test developed using the [VUnit](https://vunit.github.io/) testing framework for VHDL.

# Release Generation
The changelog shall be updated on every release using [semantic versioning](https://semver.org/).

The master branch shall always be at the latest stable release state.

The released features shall be pulled into the corresponding  submodule within the [en\_vhdl\_all](https://gitlab.enclustra.com/Enclustra/Lib/Fw/VHDL/en_vhdl_all) repository and regression tests shall successfully complete.