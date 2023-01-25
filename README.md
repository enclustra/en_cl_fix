## General Information

*en_cl_fix* is a multi-language fixed-point math library for FPGA and ASIC development.

It provides fixed-point functionality in both HDL (currently VHDL) and software languages (currently Python and MATLAB). This allows fixed-point algorithms to be designed, modelled and evaluated in software, before committing to the HDL implementation. Then it allows the HDL implementation to be easily verified in simulation and/or hardware by comparing the simulation/hardware output with the bit-true software model's output.

This library supports arbitrary precision, but software executes faster for bit-widths ≤ 53 bits.

## License
This library is free and open-source.

It is published under [PSI HDL Library License](License.txt), which is [LGPL](LGPL2_1.txt) plus some additional exceptions to clarify the LGPL terms in the context of firmware development.

## Maintainers
This library is maintained by [Enclustra GmbH](https://www.enclustra.com/en).

## Changelog
See [Changelog](Changelog.md).

## Dependencies

- Python
    - *numpy*
    - *vunit-hdl*
- MATLAB
    - For normal usage: None.
    - For handling very wide data (> 53 bits): [*Fixed-Point Designer Toolbox*](https://www.mathworks.com/products/fixed-point-designer.html).

## Simulations and Testbenches

* Python
  * **TBD**
* MATLAB
  * **TBD**
* VHDL
  * **TBD**

## Fixed-Point Representation

### Format

The fixed point number format used in this library is defined as follows:

```
[S, I, F]
```

where:

- `S` = Number of sign bits (0 or 1).
- `I` = Number of integer bits.
- `F` = Number of fractional bits.

Therefore, the total bit-width is simply `S`+`I`+`F`.

The contributions of the integer bits and fractional bits in a fixed-point binary number depend on their position relative to the binary point (`I` bits left, `F` bits right). This is the same concept as for an ordinary decimal number (with a decimal point), except with powers of 2 instead of powers of 10. For signed numbers, the (two's complement) sign bit carries a weight of -2<sup>i</sup>.

<img src="doc/images/BitWeights.png" alt="BitWeights" style="zoom: 67%;" />

Some examples are given below:

| Fixed-Point Format |       Range       | Bit Pattern | Example (in Decimal) | Example (in Binary) |
| :----------------: | :---------------: | :---------: | :------------------: | :-----------------: |
|      [1,2,1]       |    -4 ... +3.5    |    sii.f    |         -2.5         |           101.1     |
|      [1,2,2]       |   -4 ... +3.75    |   sii.ff    |         -2.5         |           101.10    |
|      [0,4,0]       |     0 ... 15      |    iiii.    |          5           |           0101.     |
|      [0,4,2]       |    0 ... 15.75    |   iiii.ff   |         5.25         |          0101.01    |
|      [1,4,-2]      |    -16 ... 12     |   sii--.    |          -8          |           110--.    |
|      [1,-2,4]      | -0.25 ... +0.1875 |    .-sff    |        0.125         |           .-010     |

### Rounding

Rounding behavior is relevant when the number of fractional bits `F` is decreased. This is the same concept as rounding decimal numbers, but in base 2.

Several widely-used rounding modes are implemented in *en_cl_fix*. They are summarized below:
<table> 
  <tr>
    <th rowspan="2"> Rounding Mode </th>
    <th rowspan="2"> Description </th>
    <th colspan="6"> Example values, rounded to [1,2,0] </th>
  </tr>
  <tr>
    <th> 2.2 </th> <th> 2.7 </th> <th> -1.5 </th> <th> -0.5 </th> <th> 0.5 </th> <th> 1.5 </th>
  </tr>
  <tr>
    <td> Trunc_s </td>
    <td> Truncate (discard LSBs) </td>
    <td> 2 </td> <td> 2 </td> <td> -2 </td> <td> -1 </td> <td> 0 </td> <td> 1 </td>
  </tr>
  <tr>
    <td> NonSymPos_s </td>
    <td> Non-symmetric round to +infinity </td>
    <td> 2 </td> <td> 3 </td> <td> -1 </td> <td> 0 </td> <td> 1 </td> <td> 2 </td>
  </tr>
  <tr>
    <td> NonSymNeg_s </td>
    <td> Non-symmetric round to -infinity </td>
    <td> 2 </td> <td> 3 </td> <td> -2 </td> <td> -1 </td> <td> 0 </td> <td> 1 </td>
  </tr>
  <tr>
    <td> SymInf_s </td>
    <td> Symmetric round "outwards" to +/- infinity </td>
    <td> 2 </td> <td> 3 </td> <td> -2 </td> <td> -1 </td> <td> 1 </td> <td> 2 </td>
  </tr>
  <tr>
    <td> SymZero_s </td>
    <td> Symmetric round "inwards" to zero </td>
    <td> 2 </td> <td> 3 </td> <td> -1 </td> <td> 0 </td> <td> 0 </td> <td> 1 </td>
  </tr>
  <tr>
    <td> ConvEven_s </td>
    <td> Convergent rounding to even </td>
    <td> 2 </td> <td> 3 </td> <td> -2 </td> <td> 0 </td> <td> 0 </td> <td> 2 </td>
  </tr>
  <tr>
    <td> ConvOdd_s </td>
    <td> Convergent rounding to odd </td>
    <td> 2 </td> <td> 3 </td> <td> -1 </td> <td> -1 </td> <td> 1 </td> <td> 1 </td>
  </tr>
</table>

`Trunc_s` is the most resource-efficient mode, but introduces the largest rounding error. Its integer equivalent is `floor(x)`.

`NonSymPos_s` is the most common general-purpose rounding mode. It is fairly resource-efficient, but introduces error bias because all ties are rounded towards +infinity. Its integer equivalent is `floor(x + 0.5)`.

All the other rounding modes differ from `NonSymPos_s` only with respect to how ties are handled (see table above).

### Saturation

Saturation behavior is relevant when the number of integer bits `I` is decreased and/or the number of sign bits `S` is decreased (signed to unsigned).

If saturation is not enabled, then MSBs are simply discarded, causing any out-of-range values to "wrap".

If warnings are enabled, then the HDL simulator or software environment will issue a warning when an out-of-range value is detected.

| Saturation Mode | Saturate? | Warn? |
|-----------------|-----------|-------|
| None_s          | No        | No    |
| Warn_s          | No        | Yes   |
| Sat_s           | Yes       | No    |
| SatWarn_s       | Yes       | Yes   |

## Documentation

Documentation 

- Python
  - **TBD**
- MATLAB
  - **TBD**
- VHDL
  - **TBD**
