---------------------------------------------------------------------------------------------------
-- Copyright (c) 2024 Enclustra GmbH, Switzerland (info@enclustra.com)
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software
-- and associated documentation files (the "Software"), to deal in the Software without
-- restriction, including without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all copies or
-- substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
-- BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
-- DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Libraries
---------------------------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    
library vunit_lib;
    context vunit_lib.vunit_context;
    context vunit_lib.vc_context;

library work;
    use work.en_cl_fix_pkg.all;

---------------------------------------------------------------------------------------------------
-- Entity
---------------------------------------------------------------------------------------------------

entity en_cl_fix_pkg_tb is
    generic(
        runner_cfg      : string
    );
end entity en_cl_fix_pkg_tb;

---------------------------------------------------------------------------------------------------
-- Architecture
---------------------------------------------------------------------------------------------------

architecture sim of en_cl_fix_pkg_tb is
    
    procedure check_equal(got, expected : FixFormat_t; msg : string) is
    begin
        assert got = expected report msg & ", got: " & to_string(got) & ", expected: " & to_string(expected) severity Failure;
    end procedure;
    
begin
    
    test_runner_watchdog(runner, 100 ms);
    
    ----------------
    -- VUnit Main --
    ----------------
    p_main : process
    begin
        test_runner_setup(runner, runner_cfg);
        
        while test_suite loop
            if run("test") then
                -- cl_fix_add_fmt
                print("cl_fix_add_fmt");
                check_equal(cl_fix_add_fmt((1, 1, 1), (0, 7, 0)), (1, 8, 1), "cl_fix_add_fmt Wrong");
                
                -- cl_fix_sub_fmt
                print("cl_fix_sub_fmt");
                check_equal(cl_fix_sub_fmt((1, 1, 1), (0, 7, 0)), (1, 8, 1), "cl_fix_sub_fmt Wrong");
                
                -- cl_fix_mult_fmt
                print("cl_fix_mult_fmt");
                check_equal(cl_fix_mult_fmt((1, 1, 1), (0, 7, 0)), (1, 8, 1), "cl_fix_mult_fmt Wrong");
                
                -- cl_fix_neg_fmt
                print("cl_fix_neg_fmt");
                check_equal(cl_fix_neg_fmt((0, 7, 0)), (1, 7, 0), "cl_fix_neg_fmt Wrong");
                
                -- cl_fix_shift_fmt
                print("cl_fix_shift_fmt");
                check_equal(cl_fix_shift_fmt((0, 7, 0), -5, -1), (0, 6, 5), "cl_fix_shift_fmt Wrong");
                
                -- cl_fix_shift_fmt
                print("cl_fix_shift_fmt");
                check_equal(cl_fix_shift_fmt((0, 7, 0), 4), (0, 11, -4), "cl_fix_shift_fmt Wrong");
                
                -- cl_fix_width
                print("cl_fix_width");
                check_equal(cl_fix_width((0, 3, 0)), 3, "cl_fix_width Wrong: Integer only, Unsigned, NoFractional Bits");
                check_equal(cl_fix_width((1, 3, 0)), 4, "cl_fix_width Wrong: Integer only, Signed, NoFractional Bits");
                check_equal(cl_fix_width((0, 0, 3)), 3, "cl_fix_width Wrong: Fractional only, Unsigned, No Integer Bits");
                check_equal(cl_fix_width((1, 0, 3)), 4, "cl_fix_width Wrong: Fractional only, Signed, No Integer Bits");
                check_equal(cl_fix_width((1, 3, 3)), 7, "cl_fix_width Wrong: Integer and Fractional Bits");
                check_equal(cl_fix_width((1, -2, 3)), 2, "cl_fix_width Wrong: Negative integer bits");
                check_equal(cl_fix_width((1, 3, -2)), 2, "cl_fix_width Wrong: Negative fractional bits");
                
                -- cl_fix_from_real
                print("cl_fix_from_real");
                check_equal(cl_fix_from_real(3.0, (1, 3, 0)),
                            std_logic_vector'("0011"),
                            "cl_fix_from_real Wrong: Integer only, Signed, NoFractional Bits, Positive");
                check_equal(cl_fix_from_real(-3.0, (1, 3, 0)),
                            std_logic_vector'("1101"),
                            "cl_fix_from_real Wrong: Integer only, Signed, NoFractional Bits, Negative");
                check_equal(cl_fix_from_real(3.0, (0, 3, 0)),
                            std_logic_vector'("011"),
                            "cl_fix_from_real Wrong: Integer only, Unsigned, NoFractional Bits, Positive");
                check_equal(cl_fix_from_real(-3.25, (1, 3, 2)),
                            std_logic_vector'("110011"),
                            "cl_fix_from_real Wrong: Integer and Fractional");
                check_equal(cl_fix_from_real(-3.24, (1, 3, 1)),
                            std_logic_vector'("11010"),
                            "cl_fix_from_real Wrong: Rounding");
                check_equal(cl_fix_from_real(0.125, (0, -1, 3)),
                            std_logic_vector'("01"),
                            "cl_fix_from_real Wrong: Negative Integer Bits");
                check_equal(cl_fix_from_real(4.0, (1, 3, -1)),
                            std_logic_vector'("010"),
                            "cl_fix_from_real Wrong: Negative Fractional Bits");
                            
                -- cl_fix_to_real
                print("cl_fix_to_real");
                check_equal(cl_fix_to_real(cl_fix_from_real(3.0, (1, 3, 0)), (1, 3, 0)),
                            3.0,
                            "cl_fix_to_real Wrong: Integer only, Signed, NoFractional Bits, Positive");
                check_equal(cl_fix_to_real(cl_fix_from_real(-3.0, (1, 3, 0)), (1, 3, 0)),
                            -3.0,
                            "cl_fix_to_real Wrong: Integer only, Signed, NoFractional Bits, Negative");
                check_equal(cl_fix_to_real(cl_fix_from_real(3.0, (0, 3, 0)), (0, 3, 0)),
                            3.0,
                            "cl_fix_to_real Wrong: Integer only, Unsigned, NoFractional Bits, Positive");
                check_equal(cl_fix_to_real(cl_fix_from_real(-3.25, (1, 3, 2)), (1, 3, 2)),
                            -3.25,
                            "cl_fix_to_real Wrong: Integer and Fractional");
                check_equal(cl_fix_to_real(cl_fix_from_real(-3.24, (1, 3, 1)), (1, 3, 1)),
                            -3.0,
                            "cl_fix_to_real Wrong: Rounding");
                check_equal(cl_fix_to_real(cl_fix_from_real(0.125, (0, -1, 3)), (0, -1, 3)),
                            0.125,
                            "cl_fix_to_real Wrong: Negative Integer Bits");
                check_equal(cl_fix_to_real(cl_fix_from_real(4.0, (1, 3, -1)), (1, 3, -1)),
                            4.0,
                            "cl_fix_to_real Wrong: Negative Fractional Bits");
                            
                -- cl_fix_from_integer
                print("cl_fix_from_integer");
                check_equal(cl_fix_from_integer(3, (0, 4, 0)), std_logic_vector'("0011"), "cl_fix_from_integer: Unsigned Positive");
                check_equal(cl_fix_from_integer(3, (1, 3, 0)), std_logic_vector'("0011"), "cl_fix_from_integer: Signed Positive");
                check_equal(cl_fix_from_integer(-3, (1, 3, 0)), std_logic_vector'("1101"), "cl_fix_from_integer: Signed Negative");
                check_equal(cl_fix_from_integer(-3, (1, 1, 2)), std_logic_vector'("1101"), "cl_fix_from_integer: Fractional"); -- binary point position is not important
                check_equal(cl_fix_from_integer(17, (0, 4, 0)), std_logic_vector'("0001"), "cl_fix_from_integer: Wrap Unsigned");
                
                -- cl_fix_to_integer
                print("cl_fix_to_integer");
                check_equal(cl_fix_to_integer("11", (0,2,0)), 3, "cl_fix_to_integer: Unsigned Positive");
                check_equal(cl_fix_to_integer("011", (1,2,0)), 3, "cl_fix_to_integer: Signed Positive");
                check_equal(cl_fix_to_integer("1101", (1,3,0)), -3, "cl_fix_to_integer: Signed Negative");
                check_equal(cl_fix_to_integer("1101", (1,1,2)), -3, "cl_fix_to_integer: Fractional"); -- binary point position is not important
                
                -- cl_fix_resize
                print("cl_fix_resize");
                check_equal(cl_fix_resize("0101", (1, 2, 1), (1, 2, 1)), std_logic_vector'("0101"),
                            "cl_fix_resize: No formatchange");
                            
                check_equal(cl_fix_resize("0101", (1, 2, 1), (1, 2, 0), Trunc_s), std_logic_vector'("010"),
                            "cl_fix_resize: Remove Frac Bit 1 Trunc");
                check_equal(cl_fix_resize("0101", (1, 2, 1), (1, 2, 0), NonSymPos_s), std_logic_vector'("011"),
                            "cl_fix_resize: Remove Frac Bit 1 Round");
                check_equal(cl_fix_resize("0100", (1, 2, 1), (1, 2, 0), Trunc_s), std_logic_vector'("010"),
                            "cl_fix_resize: Remove Frac Bit 0 Trunc");
                check_equal(cl_fix_resize("0100", (1, 2, 1), (1, 2, 0), NonSymPos_s), std_logic_vector'("010"),
                            "cl_fix_resize: Remove Frac Bit 0 Round");
                            
                check_equal(cl_fix_resize("0100", (1, 2, 1), (1, 2, 2), NonSymPos_s), std_logic_vector'("01000"),
                            "cl_fix_resize: Add Fractional Bit Signed");
                check_equal(cl_fix_resize("100", (0, 2, 1), (0, 2, 2), NonSymPos_s), std_logic_vector'("1000"),
                            "cl_fix_resize: Add Fractional Bit Unsigned");
                            
                check_equal(cl_fix_resize("00111", (1, 3, 1), (1, 2, 1), Trunc_s, None_s), std_logic_vector'("0111"),
                            "cl_fix_resize: Remove Integer Bit, Signed, NoSat, Positive");
                check_equal(cl_fix_resize("11001", (1, 3, 1), (1, 2, 1), Trunc_s, Sat_s), std_logic_vector'("1001"),
                            "cl_fix_resize: Remove Integer Bit, Signed, NoSat, Negative");
                check_equal(cl_fix_resize("01011", (1, 3, 1), (1, 2, 1), Trunc_s, None_s), std_logic_vector'("1011"),
                            "cl_fix_resize: Remove Integer Bit, Signed, Wrap, Positive");
                check_equal(cl_fix_resize("10011", (1, 3, 1), (1, 2, 1), Trunc_s, None_s), std_logic_vector'("0011"),
                            "cl_fix_resize: Remove Integer Bit, Signed, Wrap, Negative");
                check_equal(cl_fix_resize("01011", (1, 3, 1), (1, 2, 1), Trunc_s, Sat_s), std_logic_vector'("0111"),
                            "cl_fix_resize: Remove Integer Bit, Signed, Sat, Positive");
                check_equal(cl_fix_resize("10011", (1, 3, 1), (1, 2, 1), Trunc_s, Sat_s), std_logic_vector'("1000"),
                            "cl_fix_resize: Remove Integer Bit, Signed, Sat, Negative");
                            
                check_equal(cl_fix_resize("0111", (0, 3, 1), (0, 2, 1), Trunc_s, None_s), std_logic_vector'("111"),
                            "cl_fix_resize: Remove Integer Bit, Unsigned, NoSat, Positive");
                check_equal(cl_fix_resize("1011", (0, 3, 1), (0, 2, 1), Trunc_s, None_s), std_logic_vector'("011"),
                            "cl_fix_resize: Remove Integer Bit, Unsigned, Wrap, Positive");
                check_equal(cl_fix_resize("1011", (0, 3, 1), (0, 2, 1), Trunc_s, Sat_s), std_logic_vector'("111"),
                            "cl_fix_resize: Remove Integer Bit, Unsigned, Sat, Positive");
                            
                check_equal(cl_fix_resize("00111", (1, 3, 1), (0, 3, 1), Trunc_s, None_s), std_logic_vector'("0111"),
                            "cl_fix_resize: Remove Sign Bit, Signed, NoSat, Positive");
                check_equal(cl_fix_resize("10011", (1, 3, 1), (0, 3, 1), Trunc_s, None_s), std_logic_vector'("0011"),
                            "cl_fix_resize: Remove Sign Bit, Signed, Wrap, Negative");
                check_equal(cl_fix_resize("10011", (1, 3, 1), (0, 3, 1), Trunc_s, Sat_s), std_logic_vector'("0000"),
                            "cl_fix_resize: Remove Sign Bit, Signed, Sat, Negative");
                            
                check_equal(cl_fix_resize("01111", (1, 3, 1), (1, 3, 0), NonSymPos_s, None_s), std_logic_vector'("1000"),
                            "cl_fix_resize: Overflow due rounding, Signed, Wrap");
                check_equal(cl_fix_resize("01111", (1, 3, 1), (1, 3, 0), NonSymPos_s, Sat_s), std_logic_vector'("0111"),
                            "cl_fix_resize: Overflow due rounding, Signed, Sat");
                check_equal(cl_fix_resize("1111", (0, 3, 1), (0, 3, 0), NonSymPos_s, None_s), std_logic_vector'("000"),
                            "cl_fix_resize: Overflow due rounding, Unsigned, Wrap");
                check_equal(cl_fix_resize("1111", (0, 3, 1), (0, 3, 0), NonSymPos_s, Sat_s), std_logic_vector'("111"),
                            "cl_fix_resize: Overflow due rounding, Unsigned, Sat");
                            
                check_equal(cl_fix_resize("11111", (1, 3, 1), (1, 3, 0), NonSymNeg_s, None_s), std_logic_vector'("1111"),
                            "cl_fix_resize: NonSymNeg_s -0.5");
                check_equal(cl_fix_resize("11101", (1, 3, 1), (1, 3, 0), NonSymNeg_s, None_s), std_logic_vector'("1110"),
                            "cl_fix_resize: NonSymNeg_s -1.5");
                check_equal(cl_fix_resize("00001", (1, 3, 1), (1, 3, 0), NonSymNeg_s, None_s), std_logic_vector'("0000"),
                            "cl_fix_resize: NonSymNeg_s 0.5");
                check_equal(cl_fix_resize("00011", (1, 3, 1), (1, 3, 0), NonSymNeg_s, None_s), std_logic_vector'("0001"),
                            "cl_fix_resize: NonSymNeg_s 1.5");
                check_equal(cl_fix_resize("000111", (1, 3, 2), (1, 3, 0), NonSymNeg_s, None_s), std_logic_vector'("0010"),
                            "cl_fix_resize: NonSymNeg_s 1.75");
                            
                check_equal(cl_fix_resize("11111", (1, 3, 1), (1, 3, 0), SymInf_s, None_s), std_logic_vector'("1111"),
                            "cl_fix_resize: SymInf_s -0.5");
                check_equal(cl_fix_resize("11101", (1, 3, 1), (1, 3, 0), SymInf_s, None_s), std_logic_vector'("1110"),
                            "cl_fix_resize: SymInf_s -1.5");
                check_equal(cl_fix_resize("00001", (1, 3, 1), (1, 3, 0), SymInf_s, None_s), std_logic_vector'("0001"),
                            "cl_fix_resize: SymInf_s 0.5");
                check_equal(cl_fix_resize("00011", (1, 3, 1), (1, 3, 0), SymInf_s, None_s), std_logic_vector'("0010"),
                            "cl_fix_resize: SymInf_s 1.5");
                check_equal(cl_fix_resize("000111", (1, 3, 2), (1, 3, 0), SymInf_s, None_s), std_logic_vector'("0010"),
                            "cl_fix_resize: SymInf_s 1.75");
                            
                check_equal(cl_fix_resize("11111", (1, 3, 1), (1, 3, 0), SymZero_s, None_s), std_logic_vector'("0000"),
                            "cl_fix_resize: SymZero_s -0.5");
                check_equal(cl_fix_resize("11101", (1, 3, 1), (1, 3, 0), SymZero_s, None_s), std_logic_vector'("1111"),
                            "cl_fix_resize: SymZero_s -1.5");
                check_equal(cl_fix_resize("00001", (1, 3, 1), (1, 3, 0), SymZero_s, None_s), std_logic_vector'("0000"),
                            "cl_fix_resize: SymZero_s 0.5");
                check_equal(cl_fix_resize("00011", (1, 3, 1), (1, 3, 0), SymZero_s, None_s), std_logic_vector'("0001"),
                            "cl_fix_resize: SymZero_s 1.5");
                check_equal(cl_fix_resize("000111", (1, 3, 2), (1, 3, 0), SymZero_s, None_s), std_logic_vector'("0010"),
                            "cl_fix_resize: SymZero_s 1.75");
                            
                check_equal(cl_fix_resize("11111", (1, 3, 1), (1, 3, 0), ConvEven_s, None_s), std_logic_vector'("0000"),
                            "cl_fix_resize: ConvEven_s -0.5");
                check_equal(cl_fix_resize("11101", (1, 3, 1), (1, 3, 0), ConvEven_s, None_s), std_logic_vector'("1110"),
                            "cl_fix_resize: ConvEven_s -1.5");
                check_equal(cl_fix_resize("00001", (1, 3, 1), (1, 3, 0), ConvEven_s, None_s), std_logic_vector'("0000"),
                            "cl_fix_resize: ConvEven_s 0.5");
                check_equal(cl_fix_resize("00011", (1, 3, 1), (1, 3, 0), ConvEven_s, None_s), std_logic_vector'("0010"),
                            "cl_fix_resize: ConvEven_s 1.5");
                check_equal(cl_fix_resize("000111", (1, 3, 2), (1, 3, 0), ConvEven_s, None_s), std_logic_vector'("0010"),
                            "cl_fix_resize: ConvEven_s 1.75");
                            
                check_equal(cl_fix_resize("11111", (1, 3, 1), (1, 3, 0), ConvOdd_s, None_s), std_logic_vector'("1111"),
                            "cl_fix_resize: ConvOdd_s -0.5");
                check_equal(cl_fix_resize("11101", (1, 3, 1), (1, 3, 0), ConvOdd_s, None_s), std_logic_vector'("1111"),
                            "cl_fix_resize: ConvOdd_s -1.5");
                check_equal(cl_fix_resize("00001", (1, 3, 1), (1, 3, 0), ConvOdd_s, None_s), std_logic_vector'("0001"),
                            "cl_fix_resize: ConvOdd_s 0.5");
                check_equal(cl_fix_resize("00011", (1, 3, 1), (1, 3, 0), ConvOdd_s, None_s), std_logic_vector'("0001"),
                            "cl_fix_resize: ConvOdd_s 1.5");
                check_equal(cl_fix_resize("000111", (1, 3, 2), (1, 3, 0), ConvOdd_s, None_s), std_logic_vector'("0010"),
                            "cl_fix_resize: ConvOdd_s 1.75");
                            
                -- error cases
                check_equal(cl_fix_resize(cl_fix_from_real(2.5, (0, 5, 4)), (0, 5, 4), (0, 6, 4)), std_logic_vector'("0000101000"),
                            "cl_fix_resize: Overflow due rounding, Unsigned, Sat");
                check_equal(cl_fix_resize(cl_fix_from_real(1.25, (0, 5, 3)), (0, 5, 3), (0, 5, 4)), std_logic_vector'("000010100"),
                            "cl_fix_resize: Overflow due rounding, Unsigned, Sat");
                            
                -- cl_fix_add
                print("cl_fix_add");
                check_equal(cl_fix_add(cl_fix_from_real(-2.5, (1, 5, 3)), (1, 5, 3),
                                        cl_fix_from_real(1.25, (1, 5, 3)), (1, 5, 3),
                                        (1, 5, 3)),
                            cl_fix_from_real(-2.5+1.25, (1, 5, 3)),
                            "cl_fix_add: Same Fmt Signed");
                check_equal(cl_fix_add(cl_fix_from_real(2.5, (0, 5, 3)), (0, 5, 3),
                                        cl_fix_from_real(1.25, (0, 5, 3)), (0, 5, 3),
                                        (0, 5, 3)),
                            cl_fix_from_real(2.5+1.25, (0, 5, 3)),
                            "cl_fix_add: Same Fmt Usigned");
                check_equal(cl_fix_add(cl_fix_from_real(-2.5, (1, 6, 3)), (1, 6, 3),
                                        cl_fix_from_real(1.25, (1, 5, 3)), (1, 5, 3),
                                        (1, 5, 3)),
                            cl_fix_from_real(-2.5+1.25, (1, 5, 3)),
                            "cl_fix_add: Different Int Bits Signed");
                check_equal(cl_fix_add(cl_fix_from_real(2.5, (0, 6, 3)), (0, 6, 3),
                                        cl_fix_from_real(1.25, (0, 5, 3)), (0, 5, 3),
                                        (0, 5, 3)),
                            cl_fix_from_real(2.5+1.25, (0, 5, 3)),
                            "cl_fix_add: Different Int Bits Usigned");
                check_equal(cl_fix_add(cl_fix_from_real(-2.5, (1, 5, 4)), (1, 5, 4),
                                        cl_fix_from_real(1.25, (1, 5, 3)), (1, 5, 3),
                                        (1, 5, 3)),
                            cl_fix_from_real(-2.5+1.25, (1, 5, 3)),
                            "cl_fix_add: Different Frac Bits Signed");
                check_equal(cl_fix_add(cl_fix_from_real(2.5, (0, 5, 4)), (0, 5, 4),
                                        cl_fix_from_real(1.25, (0, 5, 3)), (0, 5, 3),
                                        (0, 5, 3)),
                            cl_fix_from_real(2.5+1.25, (0, 5, 3)),
                            "cl_fix_add: Different Frac Bits Usigned");
                check_equal(cl_fix_add(cl_fix_from_real(0.75, (0, 0, 4)), (0, 0, 4),
                                        cl_fix_from_real(4.0, (0, 4, -1)), (0, 4, -1),
                                        (0, 5, 5)),
                            cl_fix_from_real(0.75+4.0, (0, 5, 5)),
                            "cl_fix_add: Different Ranges Unsigned");
                check_equal(cl_fix_add(cl_fix_from_real(0.75, (0, 0, 4)), (0, 0, 4),
                                        cl_fix_from_real(4.0, (0, 4, -1)), (0, 4, -1),
                                        (0, 5, 0), NonSymPos_s),
                            cl_fix_from_real(5.0, (0, 5, 0)),
                            "cl_fix_add: Round");
                check_equal(cl_fix_add(cl_fix_from_real(0.75, (0, 0, 4)), (0, 0, 4),
                                        cl_fix_from_real(15.0, (0, 4, 0)), (0, 4, 0),
                                        (0, 4, 0), NonSymPos_s, Sat_s),
                            cl_fix_from_real(15.0, (0, 4, 0)),
                            "cl_fix_add: Satturate");
                            
                -- cl_fix_sub
                print("cl_fix_sub");
                check_equal(cl_fix_sub(cl_fix_from_real(-2.5, (1, 5, 3)), (1, 5, 3),
                                        cl_fix_from_real(1.25, (1, 5, 3)), (1, 5, 3),
                                        (1, 5, 3)),
                            cl_fix_from_real(-2.5-1.25, (1, 5, 3)),
                            "cl_fix_sub: Same Fmt Signed");
                check_equal(cl_fix_sub(cl_fix_from_real(2.5, (0, 5, 3)), (0, 5, 3),
                                        cl_fix_from_real(1.25, (0, 5, 3)), (0, 5, 3),
                                        (0, 5, 3)),
                            cl_fix_from_real(2.5-1.25, (0, 5, 3)),
                            "cl_fix_sub: Same Fmt Usigned");
                check_equal(cl_fix_sub(cl_fix_from_real(-2.5, (1, 6, 3)), (1, 6, 3),
                                        cl_fix_from_real(1.25, (1, 5, 3)), (1, 5, 3),
                                        (1, 5, 3)),
                            cl_fix_from_real(-2.5-1.25, (1, 5, 3)),
                            "cl_fix_sub: Different Int Bits Signed");
                check_equal(cl_fix_sub(cl_fix_from_real(2.5, (0, 6, 3)), (0, 6, 3),
                                        cl_fix_from_real(1.25, (0, 5, 3)), (0, 5, 3),
                                        (0, 5, 3)),
                            cl_fix_from_real(2.5-1.25, (0, 5, 3)),
                            "cl_fix_sub: Different Int Bits Usigned");
                check_equal(cl_fix_sub(cl_fix_from_real(-2.5, (1, 5, 4)), (1, 5, 4),
                                        cl_fix_from_real(1.25, (1, 5, 3)), (1, 5, 3),
                                        (1, 5, 3)),
                            cl_fix_from_real(-2.5-1.25, (1, 5, 3)),
                            "cl_fix_sub: Different Frac Bits Signed");
                check_equal(cl_fix_sub(cl_fix_from_real(2.5, (0, 5, 4)), (0, 5, 4),
                                        cl_fix_from_real(1.25, (0, 5, 3)), (0, 5, 3),
                                        (0, 5, 3)),
                            cl_fix_from_real(2.5-1.25, (0, 5, 3)),
                            "cl_fix_sub: Different Frac Bits Usigned");
                check_equal(cl_fix_sub(cl_fix_from_real(4.0, (0, 4, -1)), (0, 4, -1),
                                        cl_fix_from_real(0.75, (0, 0, 4)), (0, 0, 4),
                                        (0, 5, 5)),
                            cl_fix_from_real(4.0-0.75, (0, 5, 5)),
                            "cl_fix_sub: Different Ranges Unsigned");
                check_equal(cl_fix_sub(cl_fix_from_real(4.0, (0, 4, -1)), (0, 4, -1),
                                        cl_fix_from_real(0.25, (0, 0, 4)), (0, 0, 4),
                                        (0, 5, 0), NonSymPos_s),
                            cl_fix_from_real(4.0, (0, 5, 0)),
                            "cl_fix_sub: Round");
                check_equal(cl_fix_from_real(0.0, (0, 4, 0)),
                            cl_fix_sub(cl_fix_from_real(0.75, (0, 0, 4)), (0, 0, 4),
                                        cl_fix_from_real(5.0, (0, 4, 0)), (0, 4, 0),
                                        (0, 4, 0), NonSymPos_s, Sat_s),
                            "cl_fix_sub: Satturate");
                check_equal(cl_fix_sub(cl_fix_from_real(0.0, (1, 4, 0)), (1, 4, 0),
                                        cl_fix_from_real(-16.0, (1, 4, 0)), (1, 4, 0),
                                        (1, 4, 0), NonSymPos_s, None_s),
                            cl_fix_from_real(-16.0, (1, 4, 0)),
                            "cl_fix_sub: Invert most negative signed, noSat");
                check_equal(cl_fix_from_real(15.0, (1, 4, 0)),
                            cl_fix_sub(cl_fix_from_real(0.0, (1, 4, 0)), (1, 4, 0),
                                        cl_fix_from_real(-16.0, (1, 4, 0)), (1, 4, 0),
                                        (1, 4, 0), NonSymPos_s, Sat_s),
                            "cl_fix_sub: Invert most negative signed, Sat");
                check_equal(cl_fix_sub(cl_fix_from_real(0.0, (0, 4, 0)), (0, 4, 0),
                                        cl_fix_from_real(15.0, (0, 4, 0)), (0, 4, 0),
                                        (0, 4, 0), NonSymPos_s, None_s),
                            cl_fix_from_real(1.0, (0, 4, 0)),
                            "cl_fix_sub: Invert most negative unsigned, noSat");
                check_equal(cl_fix_sub(cl_fix_from_real(0.0, (0, 4, 0)), (0, 4, 0),
                                        cl_fix_from_real(15.0, (0, 4, 0)), (0, 4, 0),
                                        (0, 4, 0), NonSymPos_s, Sat_s),
                            cl_fix_from_real(0.0, (0, 4, 0)),
                            "cl_fix_sub: Invert unsigned, Sat");
                            
                -- cl_fix_mult
                print("cl_fix_mult");
                check_equal(cl_fix_mult(cl_fix_from_real(2.5, (0, 5, 1)), (0, 5, 1),
                                        cl_fix_from_real(1.25, (0, 5, 2)), (0, 5, 2),
                                        (0, 5, 5)),
                            cl_fix_from_real(2.5*1.25, (0, 5, 5)),
                            "cl_fix_mult: A unsigned positive, B unsigned positive");
                check_equal(cl_fix_mult(cl_fix_from_real(2.5, (1, 2, 1)), (1, 2, 1),
                                        cl_fix_from_real(1.25, (1, 1, 2)), (1, 1, 2),
                                        (1, 3, 3)),
                            cl_fix_from_real(2.5*1.25, (1, 3, 3)),
                            "cl_fix_mult: A signed positive, B signed positive");
                check_equal(cl_fix_mult(cl_fix_from_real(2.5, (1, 2, 1)), (1, 2, 1),
                                        cl_fix_from_real(-1.25, (1, 1, 2)), (1, 1, 2),
                                        (1, 3, 3)),
                            cl_fix_from_real(2.5*(-1.25), (1, 3, 3)),
                            "cl_fix_mult: A signed positive, B signed negative");
                check_equal(cl_fix_mult(cl_fix_from_real(-2.5, (1, 2, 1)), (1, 2, 1),
                                        cl_fix_from_real(1.25, (1, 1, 2)), (1, 1, 2),
                                        (1, 3, 3)),
                            cl_fix_from_real((-2.5)*1.25, (1, 3, 3)),
                            "cl_fix_mult: A signed negative, B signed positive");
                check_equal(cl_fix_mult(cl_fix_from_real(-2.5, (1, 2, 1)), (1, 2, 1),
                                        cl_fix_from_real(-1.25, (1, 1, 2)), (1, 1, 2),
                                        (1, 3, 3)),
                            cl_fix_from_real((-2.5)*(-1.25), (1, 3, 3)),
                            "cl_fix_mult: A signed negative, B signed negative");
                check_equal(cl_fix_mult(cl_fix_from_real(2.5, (0, 2, 1)), (0, 2, 1),
                                        cl_fix_from_real(1.25, (1, 1, 2)), (1, 1, 2),
                                        (1, 3, 3)),
                            cl_fix_from_real(2.5*1.25, (1, 3, 3)),
                            "cl_fix_mult: A unsigned positive, B signed positive");
                check_equal(cl_fix_mult(cl_fix_from_real(2.5, (0, 2, 1)), (0, 2, 1),
                                        cl_fix_from_real(-1.25, (1, 1, 2)), (1, 1, 2),
                                        (1, 3, 3)),
                            cl_fix_from_real(2.5*(-1.25), (1, 3, 3)),
                            "cl_fix_mult: A unsigned positive, B signed negative");
                check_equal(cl_fix_mult(cl_fix_from_real(2.5, (0, 2, 1)), (0, 2, 1),
                                        cl_fix_from_real(1.25, (1, 1, 2)), (1, 1, 2),
                                        (0, 3, 3)),
                            cl_fix_from_real(2.5*1.25, (0, 3, 3)),
                            "cl_fix_mult: A unsigned positive, B signed positive, result unsigned");
                check_equal(cl_fix_mult(cl_fix_from_real(2.5, (0, 2, 1)), (0, 2, 1),
                                        cl_fix_from_real(1.25, (1, 1, 2)), (1, 1, 2),
                                        (0, 1, 3), Trunc_s, Sat_s),
                            cl_fix_from_real(1.875, (0, 1, 3)),
                            "cl_fix_mult: A unsigned positive, B signed positive, saturate");
                            
                -- cl_fix_abs
                print("cl_fix_abs");
                check_equal(cl_fix_abs(cl_fix_from_real(2.5, (0, 5, 1)), (0, 5, 1),
                                        (0, 5, 5)),
                            cl_fix_from_real(2.5, (0, 5, 5)),
                            "cl_fix_abs: positive stay positive");
                check_equal(cl_fix_abs(cl_fix_from_real(-4.0, (1, 2, 2)), (1, 2, 2),
                                        (1, 3, 3)),
                            cl_fix_from_real(4.0, (1, 3, 3)),
                            "cl_fix_abs: negative becomes positive");
                check_equal(cl_fix_abs(cl_fix_from_real(-4.0, (1, 2, 2)), (1, 2, 2),
                                        (1, 2, 2), Trunc_s, Sat_s),
                            cl_fix_from_real(3.75, (1, 2, 2)),
                            "cl_fix_abs: most negative value sat");
                            
                -- cl_fix_neg
                print("cl_fix_neg");
                check_equal(cl_fix_neg(cl_fix_from_real(2.5, (1, 5, 1)), (1, 5, 1),
                                        (1, 5, 5)),
                            cl_fix_from_real(-2.5, (1, 5, 5)),
                            "cl_fix_neg: positive to negative (signed -> signed)");
                check_equal(cl_fix_neg(cl_fix_from_real(2.5, (0, 5, 1)), (0, 5, 1),
                                        (1, 5, 5)),
                            cl_fix_from_real(-2.5, (1, 5, 5)),
                            "cl_fix_neg: positive to negative (unsigned -> signed)");
                check_equal(cl_fix_neg(cl_fix_from_real(-2.5, (1, 5, 1)), (1, 5, 1),
                                        (1, 5, 5)),
                            cl_fix_from_real(2.5, (1, 5, 5)),
                            "cl_fix_neg: negative to positive (signed -> signed)");
                check_equal(cl_fix_neg(cl_fix_from_real(-2.5, (1, 5, 1)), (1, 5, 1),
                                        (0, 5, 5)),
                            cl_fix_from_real(2.5, (0, 5, 5)),
                            "cl_fix_neg: negative to positive (signed -> unsigned)");
                check_equal(cl_fix_neg(cl_fix_from_real(-4.0, (1, 2, 4)), (1, 2, 4),
                                        (1, 2, 2), Trunc_s, Sat_s),
                            cl_fix_from_real(3.75, (1, 2, 2)),
                            "cl_fix_neg: saturation (signed -> signed)");
                check_equal(cl_fix_neg(cl_fix_from_real(-4.0, (1, 2, 4)), (1, 2, 4),
                                        (1, 2, 2), Trunc_s, None_s),
                            cl_fix_from_real(-4.0, (1, 2, 2)),
                            "cl_fix_neg: wrap (signed -> signed)");
                check_equal(cl_fix_neg(cl_fix_from_real(2.5, (1, 5, 1)), (1, 5, 1),
                                        (0, 5, 5), Trunc_s, Sat_s),
                            cl_fix_from_real(0.0, (0, 5, 5)),
                            "cl_fix_neg: positive to negative saturate (signed -> unsigned)");
                            
                -- cl_fix_shift left***
                print("cl_fix_shift left");
                check_equal(cl_fix_shift(cl_fix_from_real(1.25, (0, 3, 2)),  (0, 3, 2),
                                            1,
                                            (0, 3, 2)),
                            cl_fix_from_real(2.5, (0, 3, 2)),
                            "Shift same format unsigned");
                check_equal(cl_fix_shift(cl_fix_from_real(1.25, (1, 3, 2)),   (1, 3, 2),
                                            1,
                                            (1, 3, 2)),
                            cl_fix_from_real(2.5, (1, 3, 2)),
                            "Shift same format signed");
                check_equal(cl_fix_shift(cl_fix_from_real(1.25, (1, 1, 2)),   (1, 1, 2),
                                            1,
                                            (0, 3, 2)),
                            cl_fix_from_real(2.5, (0, 3, 2)),
                            "Shift format change");
                check_equal(cl_fix_shift(cl_fix_from_real(2.0, (1, 2, 2)),    (1, 2, 2),
                                            1,
                                            (1, 2, 2), Trunc_s, Sat_s),
                            cl_fix_from_real(3.75, (1, 2, 2)),
                            "saturation signed");
                check_equal(cl_fix_shift(cl_fix_from_real(2.0, (0, 3, 2)),   (0, 3, 2),
                                            1,
                                            (1, 2, 2), Trunc_s, Sat_s),
                            cl_fix_from_real(3.75, (1, 2, 2)),
                            "saturation unsigned to signed");
                check_equal(cl_fix_shift(cl_fix_from_real(-0.5, (1, 3, 2)),   (1, 3, 2),
                                            1,
                                            (0, 2, 2), Trunc_s, Sat_s),
                            cl_fix_from_real(0.0, (0, 2, 2)),
                            "saturation signed to unsigned");
                check_equal(cl_fix_shift(cl_fix_from_real(2.0, (1, 2, 2)),    (1, 2, 2),
                                            1,
                                            (1, 2, 2), Trunc_s, None_s),
                            cl_fix_from_real(-4.0, (1, 2, 2)),
                            "wrap signed");
                check_equal(cl_fix_shift(cl_fix_from_real(2.0, (0, 3, 2)),   (0, 3, 2),
                                            1,
                                            (1, 2, 2), Trunc_s, None_s),
                            cl_fix_from_real(-4.0, (1, 2, 2)),
                            "wrap unsigned to signed");
                check_equal(cl_fix_shift(cl_fix_from_real(-0.5, (1, 3, 2)), (1, 3, 2),
                                            1,
                                            (0, 2, 2), Trunc_s, None_s),
                            cl_fix_from_real(3.0, (0, 2, 2)),
                            "wrap signed to unsigned");
                check_equal(cl_fix_shift(cl_fix_from_real(0.5, (1, 5, 5)), (1, 5, 5),
                                            0,
                                            (1, 5, 5), Trunc_s, None_s),
                            cl_fix_from_real(0.5, (1, 5, 5)),
                            "shift 0");
                check_equal(cl_fix_shift(cl_fix_from_real(-0.5, (1, 5, 5)), (1, 5, 5),
                                            3,
                                            (1, 5, 5), Trunc_s, None_s),
                            cl_fix_from_real(-4.0, (1, 5, 5)),
                            "shift 3");
                                            
                -- cl_fix_shift right
                print("cl_fix_shift right ");
                check_equal(cl_fix_shift(cl_fix_from_real(2.5, (0, 3, 2)),   (0, 3, 2),
                                            -1,
                                            (0, 3, 2)),
                            cl_fix_from_real(1.25, (0, 3, 2)),
                            "Shift same format unsigned");
                check_equal(cl_fix_shift(cl_fix_from_real(2.5, (1, 3, 2)),    (1, 3, 2),
                                            -1,
                                            (1, 3, 2)),
                            cl_fix_from_real(1.25, (1, 3, 2)),
                            "Shift same format signed");
                check_equal(cl_fix_shift(cl_fix_from_real(2.5, (0, 3, 2)),   (0, 3, 2),
                                            -1,
                                            (1, 1, 2)),
                            cl_fix_from_real(1.25, (1, 1, 2)),
                            "Shift format change");
                check_equal(cl_fix_shift(cl_fix_from_real(-0.5, (1, 3, 2)),   (1, 3, 2),
                                            -1,
                                            (0, 2, 2), Trunc_s, Sat_s),
                            cl_fix_from_real(0.0, (0, 2, 2)),
                            "saturation signed to unsigned");
                check_equal(cl_fix_shift(cl_fix_from_real(0.5, (1, 5, 5)), (1, 5, 5),
                                            0,
                                            (1, 5, 5), Trunc_s, None_s),
                            cl_fix_from_real(0.5, (1, 5, 5)),
                            "shift 0");
                check_equal(cl_fix_shift(cl_fix_from_real(-4.0, (1, 5, 5)), (1, 5, 5),
                                            -3,
                                            (1, 5, 5), Trunc_s, None_s),
                            cl_fix_from_real(-0.5, (1, 5, 5)),
                            "shift 3");
                                            
                -- cl_fix_max_value
                print("cl_fix_max_value");
                check_equal(cl_fix_max_value((0,2,2)), std_logic_vector'("1111"), "unsigned");
                check_equal(cl_fix_max_value((1,1,2)), std_logic_vector'("0111"), "signed");
                
                -- cl_fix_min_value
                print("cl_fix_min_value");
                check_equal(cl_fix_min_value((0,2,2)), std_logic_vector'("0000"), "unsigned");
                check_equal(cl_fix_min_value((1,1,2)), std_logic_vector'("1000"), "signed");
                
                -- cl_fix_in_range
                print("cl_fix_in_range");
                check_equal(cl_fix_in_range(cl_fix_from_real(1.25, (1, 4, 2)), (1, 4, 2),
                                            (1, 2, 4), Trunc_s),
                            true,
                            "In Range Normal");
                check_equal(cl_fix_in_range(cl_fix_from_real(6.25, (1, 4, 2)), (1, 4, 2),
                                            (1, 2, 4), Trunc_s),
                            false,
                            "Out Range Normal");
                check_equal(cl_fix_in_range(cl_fix_from_real(-1.25, (1, 4, 2)), (1, 4, 2),
                                            (0, 5, 2), Trunc_s),
                            false,
                            "signed -> unsigned OOR");
                check_equal(cl_fix_in_range(cl_fix_from_real(15.0, (0, 4, 2)), (0, 4, 2),
                                            (1, 3, 2), Trunc_s),
                            false,
                            "unsigned -> signed OOR");
                check_equal(cl_fix_in_range(cl_fix_from_real(15.0, (0, 4, 2)), (0, 4, 2),
                                            (1, 4, 2), Trunc_s),
                            true,
                            "unsigned -> signed OK");
                check_equal(cl_fix_in_range(cl_fix_from_real(15.5, (0, 4, 2)), (0, 4, 2),
                                            (1, 4, 0), NonSymPos_s),
                            false,
                            "rounding OOR");
                check_equal(cl_fix_in_range(cl_fix_from_real(15.5, (0, 4, 2)), (0, 4, 2),
                                            (1, 4, 1), NonSymPos_s),
                            true,
                            "rounding OK 1");
                check_equal(cl_fix_in_range(cl_fix_from_real(15.5, (0, 4, 2)), (0, 4, 2),
                                            (0, 5, 0), NonSymPos_s),
                            true,
                            "rounding OK 2");
                
                -- cl_fix_compare
                print("cl_fix_compare");
                check_equal(cl_fix_compare("<",
                                            cl_fix_from_real(1.25, (0, 4, 2)), (0, 4, 2),
                                            cl_fix_from_real(1.5, (0, 2, 1)), (0, 2, 1)),
                            true,
                            "a<b unsigned unsigned true");
                check_equal(cl_fix_compare("<",
                                            cl_fix_from_real(1.5, (0, 4, 2)), (0, 4, 2),
                                            cl_fix_from_real(1.5, (0, 2, 1)), (0, 2, 1)),
                            false,
                            "a<b unsigned unsigned false");
                check_equal(cl_fix_compare("<",
                                            cl_fix_from_real(1.25, (1, 4, 2)), (1, 4, 2),
                                            cl_fix_from_real(1.5, (0, 2, 1)), (0, 2, 1)),
                            true,
                            "a<b signed unsigned true");
                check_equal(cl_fix_compare("<",
                                            cl_fix_from_real(2.5, (0, 4, 2)), (0, 4, 2),
                                            cl_fix_from_real(1.5, (1, 2, 1)), (1, 2, 1)),
                            false,
                            "a<b unsigned signed false");
                check_equal(cl_fix_compare("<",
                                            cl_fix_from_real(-1.25, (1, 4, 2)), (1, 4, 2),
                                            cl_fix_from_real(-1.0, (1, 2, 1)), (1, 2, 1)),
                            true,
                            "a<b signed signed true");
                check_equal(cl_fix_compare("<",
                                            cl_fix_from_real(-0.5, (1, 4, 2)), (1, 4, 2),
                                            cl_fix_from_real(-1.5, (1, 2, 1)), (1, 2, 1)),
                            false,
                            "a<b signed signed false");
                                
                check_equal(cl_fix_compare("=",
                                            cl_fix_from_real(1.5, (1, 4, 2)), (1, 4, 2),
                                            cl_fix_from_real(1.5, (0, 2, 1)), (0, 2, 1)),
                            true,
                            "a=b signed unsigned true");
                check_equal(cl_fix_compare("=",
                                            cl_fix_from_real(2.5, (0, 4, 2)), (0, 4, 2),
                                            cl_fix_from_real(-1.5, (1, 2, 1)), (1, 2, 1)),
                            false,
                            "a=b unsigned signed false");
                                
                check_equal(cl_fix_compare(">",
                                            cl_fix_from_real(2.5, (1, 4, 2)), (1, 4, 2),
                                            cl_fix_from_real(1.5, (0, 2, 1)), (0, 2, 1)),
                            true,
                            "a>b signed unsigned true");
                check_equal(cl_fix_compare(">",
                                            cl_fix_from_real(1.5, (0, 4, 2)), (0, 4, 2),
                                            cl_fix_from_real(1.5, (1, 2, 1)), (1, 2, 1)),
                            false,
                            "a>b unsigned signed false");
                                
                check_equal(cl_fix_compare(">=",
                                            cl_fix_from_real(2.5, (1, 4, 2)), (1, 4, 2),
                                            cl_fix_from_real(1.5, (0, 2, 1)), (0, 2, 1)),
                            true,
                            "a>=b signed unsigned true 1");
                check_equal(cl_fix_compare(">=",
                                            cl_fix_from_real(1.5, (1, 4, 2)), (1, 4, 2),
                                            cl_fix_from_real(1.5, (0, 2, 1)), (0, 2, 1)),
                            true,
                            "a>=b signed unsigned true 2");
                check_equal(cl_fix_compare(">=",
                                            cl_fix_from_real(1.25, (0, 4, 2)), (0, 4, 2),
                                            cl_fix_from_real(1.5, (1, 2, 1)), (1, 2, 1)),
                            false,
                            "a>=b unsigned signed false 1");
                                
                check_equal(cl_fix_compare("<=",
                                            cl_fix_from_real(-2.5, (1, 4, 2)), (1, 4, 2),
                                            cl_fix_from_real(1.5, (0, 2, 1)), (0, 2, 1)),
                            true,
                            "a<=b signed unsigned true 1");
                check_equal(cl_fix_compare("<=",
                                            cl_fix_from_real(1.5, (1, 4, 2)), (1, 4, 2),
                                            cl_fix_from_real(1.5, (0, 2, 1)), (0, 2, 1)),
                            true,
                            "a<=b signed unsigned true 2");
                check_equal(cl_fix_compare("<=",
                                            cl_fix_from_real(0.25, (0, 4, 2)), (0, 4, 2),
                                            cl_fix_from_real(-1.5, (1, 2, 1)), (1, 2, 1)),
                            false,
                            "a<=b unsigned signed false 1");
                                
                check_equal(cl_fix_compare("!=",
                                            cl_fix_from_real(1.5, (1, 4, 2)), (1, 4, 2),
                                            cl_fix_from_real(1.5, (0, 2, 1)), (0, 2, 1)),
                            false,
                            "a!=b signed unsigned false");
                check_equal(cl_fix_compare("!=",
                                            cl_fix_from_real(2.5, (0, 4, 2)), (0, 4, 2),
                                            cl_fix_from_real(-1.5, (1, 2, 1)), (1, 2, 1)),
                            true,
                            "a!=b unsigned signed true");
                            
                -- cl_fix_addsub
                print("cl_fix_addsub");
                check_equal(cl_fix_addsub(cl_fix_from_real(1.0, (1,3,3)), (1,3,3),
                                          cl_fix_from_real(0.75, (1,3,3)), (1,3,3), '1', (1,3,3)),
                            cl_fix_from_real(1.75, (1,3,3)),
                            "Add");
                check_equal(cl_fix_addsub(cl_fix_from_real(1.25, (1,3,3)), (1,3,3),
                                          cl_fix_from_real(0.25, (1,3,3)), (1,3,3), '0', (1,3,3)),
                            cl_fix_from_real(1.0, (1,3,3)),
                            "Sub");
            end if;
        end loop;
        
        print("SUCCESS! All tests passed.");
        test_runner_cleanup(runner);
        wait;
    end process;
    
end sim;
