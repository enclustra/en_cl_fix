# General Information

## Owner
ET-LW: Ivan Vrbanek [ivan.vrbanek@enclustra.com]

## Maintainers
Harry Commin [harry.commin@enclustra.com]

Ivan Vrbanek [ivan.vrbanek@enclustra.com]

Tiago Gomes [tiago.gomes@enclustra.com]

## Documentation
See [documentation](doc/index.md)

## Changelog
See [changelog](CHANGELOG.md)

## Rules
The general [rules](https://gitlab.enclustra.com/enclustra/documentation/gitlabusage/-/blob/master/rules.md) for working with GitLab repositories at Enclustra apply here.

The ET-LW VHDL library specific [rules](https://gitlab.enclustra.com/Enclustra/Lib/Fw/VHDL/en_vhdl_all/-/blob/master/doc/rules.md) must be followed as well.

Use VHDL-2008 standard and Enclustra coding guidelines.

# Description
This library contains reusable VHDL code for testbench development. This library should never be used for RTL development since it contains non-synthesizable code.

# Usage
The VHDL source files from this library must be compiled into a VHDL library called `en_tb`. Use context references to include this library into the VHDL code (do not use library use clauses). Here is an example for the `en_tb_fileio_context` context:

    library en_tb;
    context en_tb.en_tb_fileio_context;

Check [documentation](doc/index.md) for the description of all defined contexts within this library.

# Dependencies

The [en\_vhdl\_all](https://gitlab.enclustra.com/Enclustra/Lib/Fw/VHDL/en_vhdl_all) repository can be used to ensure all dependencies are available. This repo contains all FPGA-related repositories as submodules in the correct folder structure and pointing at the correct release versions.

The following subset of the Enclustra VHDL libraries is required and must follow exactly the same folder structure as given below:

* (None).
