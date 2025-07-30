## 2.1.1
* Bugfixes
  * Rename min (and max) to work around name conflict issue seen only in Quartus.

## 2.1.0
* Features
  * Added testbench file I/O support (integrating lib/en_tb).
  * Added arbitrary-precision number support in MATLAB.

## 2.0.0
* Features
  * Major refactor of all VHDL code, to improve consistency, reduce clutter and improve verification.
  * Major refactor of all MATLAB code, which now just calls the Python functions.
  * Major refactor of all Python code. It now uses two separate classes to encapsulate "narrow" and "wide" number support.
  * Moved to a VUnit-based verification flow.
  * Changed FixFormat_t.Signed from boolean to integer to simplify usage. This is now consistent with psi_fix.
  * Changed FixFormat_t from (Signed, IntBits, FracBits) to (S, I, F) for brevity. This is now consistent with psi_fix.
* Bugfixes
  * Fixed cl_fix_add / cl_fix_sub bug that sometimes prevented correct inference of AMD-Xilinx DSP slice pre-adders / post-adders.

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