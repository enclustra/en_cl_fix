# General Information

The *en_cl_fix* library allows implementing the same algorithms and calculations in different languages (currently VHDL and MATLAB) easily. The main idea behind this is to evaluate the behavior or an algorithm in a high-level language such as MATLAB while implementing it later in VHDL. Thanks to the bit-true models, the correctness of the VHDL implementation can be checked easily by comparing outputs of both implementations 

## License
This library is published under [PSI HDL Library License](License.txt), which is [LGPL](LGPL2_1.txt) plus some additional exceptions to clarify the LGPL terms in the context of firmware development.

## Maintainers
Martin Heimlicher [martin.heimlicher@enclustra.com]

## Changelog
See [Changelog](Changelog.md)

## Detailed Documentation
See [VHDL Documentation](https://rawgit.com/enclustra/en_cl_fix/master/doc/vhdl_out/index.html)

## Tagging Policy
Stable releases are tagged in the form *major*.*minor*.*bugfix*. 

* Whenever a change is not fully backward compatible, the *major* version number is incremented
* Whenever new features are added, the *minor* version number is incremented
* If only bugs are fixed (i.e. no functional changes are applied), the *bugfix* version is incremented

# Simulations and Testbenches

TBD

# Fixed Point Number Format

## Format

The fixed point number format used in this library is defined as follows:

[s, i, f]

s:	true = Signed number (two's complement), false = Unsigned number
i:  Number of integer bits
f:  Number of fractional bits

The total number of bits required is s+i+f. 

The value of each bit depending on its position relative to the binary point (i-bits left, f-bits right) is given below.

... [4][2][1]**.**[0.5][0.25][0.125] ...

Some examples are given below:

| Number Format | Range             | Bit Pattern  | Example Int | Example Bits |
|:-------------:|:-----------------:|:------------:|:-----------:|:------------:|
| [true,2,1]    | -4 ... +3.5       | sii.f        | -2.5        | 101.1        |
| [true,2,2]    | -4 ... +3.75      | sii.ff       | -2.5        | 101.10       |
| [false,4,0]   | 0 ... 15          | iiii.        | 5           | 0101.        |
| [false,4,2]   | 0 ... 15.75       | iiii.ff      | 5.25        | 0101.01      |
| [true,4,-2]   | -16 ... 12        | sii--.       | -8          | 110--.       |
| [true,-2,4]   | -0.25 ... +0.1875 | s.--ff       | 0.125       | 0.--10       |

## Rounding

Several rounding modes are implemented. They are described below
<table> 
  <tr>
    <th rowspan="2"> Value </th>
    <th rowspan="2"> Description </th>
    <th colspan="6"> Examples rounded to (true,2,0) </th>
  </tr>
  <tr>
  	<th> 2.2 </th> <th> 2.7 </th> <th> -1.5 </th> <th> -0.5 </th> <th> 0.5 </th> <th> 1.5 </th>
  </tr>
  <tr>
    <td> Trunc_s </td>
    <td> Cut off bits without any rounding </td>
    <td> 2 </td> <td> 2 </td> <td> -2 </td> <td> -1 </td> <td> 0 </td> <td> 1 </td>
  </tr>
  <tr>
    <td> NonSymPos_s </td>
    <td> Non-symmetric rounding to positive </td>
    <td> 2 </td> <td> 3 </td> <td> -1 </td> <td> 0 </td> <td> 1 </td> <td> 2 </td>
  </tr>
  <tr>
    <td> NonSymNeg_s </td>
    <td> Non-symmetric rounding to negative </td>
    <td> 2 </td> <td> 3 </td> <td> -2 </td> <td> -1 </td> <td> 0 </td> <td> 1 </td>
  </tr>
  <tr>
    <td> SymInf_s </td>
    <td> Symmetric rounding to infinity </td>
    <td> 2 </td> <td> 3 </td> <td> -2 </td> <td> -1 </td> <td> 1 </td> <td> 2 </td>
  </tr>
  <tr>
    <td> SymZero_s </td>
    <td> Symmetric rounding to zero </td>
    <td> 2 </td> <td> 3 </td> <td> -1 </td> <td> 0 </td> <td> 0 </td> <td> 1 </td>
  </tr>
  <tr>
    <td> ConvEven_s </td>
    <td> Convergent rounding to even numbers </td>
    <td> 2 </td> <td> 3 </td> <td> -2 </td> <td> 0 </td> <td> 0 </td> <td> 2 </td>
  </tr>
  <tr>
    <td> ConvOdd_s </td>
    <td> Convertent rounding to odd numbers </td>
    <td> 2 </td> <td> 3 </td> <td> -1 </td> <td> -1 </td> <td> 1 </td> <td> 1 </td>
  </tr>
</table>

*NonSymPos_s* is the most common rounding mode and often aliased as *Round_s* for simplicity and readability.

**NOTE:** Use *Trunc_s* wherever possible for lowest resource usage. If rounding is required, prefer *NonSymPos_s* for low resource usage.


# Documentation

Documentation for each implementation is written in an appropriate way for the corresponding languages.

* VHDL - Doxygen
  * To re-generate the documentation, install doxygen, open the doxygen project *doc/doxy_vhdl.doxy* and run doxygen.
* MATLAB - Documentation Comments
  * The comments are displayed by matlab automatically when typing *help <command>*
  * Prerequisite is to add the path to the .m files to the MATLAB path



