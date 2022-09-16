## 1.3.0
* Features
  * Added simple format calculation functions in VHDL to mirror the Python implementation
* Bugfixes
  * Various minor improvements to wide fixed-point support
  * Fixed simulation script

## 1.2.0
* Features
  * Added wide fixed-point (> 53 bits) Python support
* Bugfixes
  * Added workaround for Xilinx Vivado bug (resolution of "mod" operator)
  * Fixed non-compliant VHDL string indexes
  * Fixed cl_fix_resize crashes when DropFracBits_c >= a'length
  * Fixed case-sensitivity bug in string_parse_boolean (VHDL)
  * Fixed inconsistency between cl_fix_in_range and cl_fix_resize (VHDL)

## 1.1.8

* Features
  * None
* Bugfixes
  * Fixed and cleaned up support for large numbers (>31 bits)
  * Fixed synthesis issues with add/sub

## 1.1.7

* Features
  * None
* Bugfixes
  * Fixed a bug in the testbench

## 1.1.6

* Features
  * None
* Bugfixes
  * Fixed "numbers > 31 bits for cl\_fix\_from\_real" for Modelsim

## 1.1.5

* Features
  * None
* Bugfixes
  * Support numbers > 31 bits for cl\_fix\_from\_real
    * In this case the result is not exact (only upper 31 bits are correct) and a warning is printed

## 1.1.4

* Features
  * None
* Bugfixes
  * Fixed bug in cl\_fix\_from\_real (saturation did not work)

## 1.1.3

* Features
  * None
* Bugfixes
  * Remove VHDL-2008 statements to make the code runnable in Vivado Simulator

## 1.1.2

* Features
  * None
* Bugfixes
  * Fixed bug in cl\_fix\_max\_real that led to problems with GHDL

## 1.1.1

* Features
  * None
* Bugfixes
  * Fixed bug in cl\_fix\_from\_real that led to integer overflows for the format (false,0,31)

## 1.1.0

* Features
  * Added Python Implementation incl. Unit-Test
  * Added Testbench for VHDL Implementation
* Bugfixes
  * None

## 1.0.0

* First Release containing VHDL and MATLAB implementations