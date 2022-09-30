---------------------------------------------------------------------------------------------------
-- Copyright (c) 2022 Enclustra GmbH, Switzerland (info@enclustra.com)
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Libraries
---------------------------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    
library std;
    use std.textio.all;
    
use work.en_cl_fix_pkg.all;

---------------------------------------------------------------------------------------------------
-- Entity
---------------------------------------------------------------------------------------------------

entity en_cl_fix_pkg_tb is
end entity en_cl_fix_pkg_tb;

---------------------------------------------------------------------------------------------------
-- Architecture
---------------------------------------------------------------------------------------------------

architecture sim of en_cl_fix_pkg_tb is

    -- Define VHDL-2008 equivalent for tools that are not VHDL 2008 capable (e.g. vivado simulator)
    function to_string( a: std_logic_vector) return string is
        variable b : string (1 to a'length) := (others => NUL);
        variable stri : integer := 1;
    begin
        for i in a'range loop
            b(stri) := std_logic'image(a((i)))(2);
            stri := stri+1;
        end loop;
        return b;
    end function;
    
    procedure CheckFmt( expected : FixFormat_t;
                        actual   : FixFormat_t;
                        msg      : string) is
    begin
        assert expected = actual
            report "###ERROR### " & msg & " [expected: " & to_string(expected) & ", got: " & to_string(actual) & "]"
            severity error;
    end procedure;
    
    procedure CheckStdlv(   expected : std_logic_vector;
                            actual   : std_logic_vector;
                            msg      : string) is
    begin
        assert expected = actual
            report "###ERROR### " & msg & " [expected: " & to_string(expected) & ", got: " & to_string(actual) & "]"
            severity error;
    end procedure;
    
    procedure CheckInt( expected : integer;
                        actual   : integer;
                        msg      : string) is
    begin
        assert expected = actual
            report "###ERROR### " & msg & " [expected: " & integer'image(expected) & ", got: " & integer'image(actual) & "]"
            severity error;
    end procedure;
    
    procedure CheckReal(    expected : real;
                            actual   : real;
                            msg      : string) is
    begin
        assert expected < actual + 1.0e-12 and expected > actual - 1.0e-12
            report "###ERROR### " & msg & " [expected: " & real'image(expected) & ", got: " & real'image(actual) & "]"
            severity error;
    end procedure;
    
    procedure CheckStdl(    expected : std_logic;
                            actual   : std_logic;
                            msg      : string) is
    begin
        assert expected = actual
            report "###ERROR### " & msg & " [expected: " & std_logic'image(expected) & ", got: " & std_logic'image(actual) & "]"
            severity error;
    end procedure;
    
    procedure CheckBoolean( expected : boolean;
                            actual   : boolean;
                            msg      : string) is
    begin
        assert expected = actual
            report "###ERROR### " & msg & " [expected: " & boolean'image(expected) & ", got: " & boolean'image(actual) & "]"
            severity error;
    end procedure;
    
    procedure print(text : string) is
        variable l : line;
    begin
        write(l, text);
        writeline(output, l);
    end procedure;
    
begin

    -----------------------------------------------------------------------------------------------
    -- TB Control
    -----------------------------------------------------------------------------------------------
    
    p_control : process
    begin
        -- *** cl_fix_add_fmt ***
        print("*** cl_fix_add_fmt ***");
        CheckFmt((1, 8, 1), cl_fix_add_fmt((1, 1, 1), (0, 7, 0)), "cl_fix_add_fmt Wrong");
        
        -- *** cl_fix_sub_fmt ***
        print("*** cl_fix_sub_fmt ***");
        CheckFmt((1, 7, 1), cl_fix_sub_fmt((1, 1, 1), (0, 7, 0)), "cl_fix_sub_fmt Wrong");
        
        -- *** cl_fix_mult_fmt ***
        print("*** cl_fix_mult_fmt ***");
        CheckFmt((1, 9, 1), cl_fix_mult_fmt((1, 1, 1), (0, 7, 0)), "cl_fix_mult_fmt Wrong");
        
        -- *** cl_fix_neg_fmt ***
        print("*** cl_fix_neg_fmt ***");
        CheckFmt((1, 7, 0), cl_fix_neg_fmt((0, 7, 0)), "cl_fix_neg_fmt Wrong");
        
        -- *** cl_fix_shift_fmt ***
        print("*** cl_fix_shift_fmt ***");
        CheckFmt((0, 6, 5), cl_fix_shift_fmt((0, 7, 0), -5, -1), "cl_fix_shift_fmt Wrong");
        
        -- *** cl_fix_shift_fmt ***
        print("*** cl_fix_shift_fmt ***");
        CheckFmt((0, 11, -4), cl_fix_shift_fmt((0, 7, 0), 4), "cl_fix_shift_fmt Wrong");
        
        -- *** cl_fix_width ***
        print("*** cl_fix_width ***");
        CheckInt(3, cl_fix_width((0, 3, 0)),    "cl_fix_width Wrong: Integer only, Unsigned, NoFractional Bits");
        CheckInt(4, cl_fix_width((1, 3, 0)),     "cl_fix_width Wrong: Integer only, Signed, NoFractional Bits");
        CheckInt(3, cl_fix_width((0, 0, 3)),    "cl_fix_width Wrong: Fractional only, Unsigned, No Integer Bits");
        CheckInt(4, cl_fix_width((1, 0, 3)),     "cl_fix_width Wrong: Fractional only, Signed, No Integer Bits");
        CheckInt(7, cl_fix_width((1, 3, 3)),     "cl_fix_width Wrong: Integer and Fractional Bits");
        CheckInt(2, cl_fix_width((1, -2, 3)),    "cl_fix_width Wrong: Negative integer bits");
        CheckInt(2, cl_fix_width((1, 3, -2)),    "cl_fix_width Wrong: Negative fractional bits");
        
        -- *** cl_fix_from_real ***
        print("*** cl_fix_from_real ***");
        CheckStdlv( "0011",
                    cl_fix_from_real(   3.0, (1, 3, 0)),
                    "cl_fix_from_real Wrong: Integer only, Signed, NoFractional Bits, Positive");
        CheckStdlv( "1101",
                    cl_fix_from_real(   -3.0, (1, 3, 0)),
                    "cl_fix_from_real Wrong: Integer only, Signed, NoFractional Bits, Negative");
        CheckStdlv( "011",
                    cl_fix_from_real(   3.0, (0, 3, 0)),
                    "cl_fix_from_real Wrong: Integer only, Unsigned, NoFractional Bits, Positive");
        CheckStdlv( "110011",
                    cl_fix_from_real(   -3.25, (1, 3, 2)),
                    "cl_fix_from_real Wrong: Integer and Fractional");
        CheckStdlv( "11010",
                    cl_fix_from_real(   -3.24, (1, 3, 1)),
                    "cl_fix_from_real Wrong: Rounding");
        CheckStdlv( "01",
                    cl_fix_from_real(   0.125, (0, -1, 3)),
                    "cl_fix_from_real Wrong: Negative Integer Bits");
        CheckStdlv( "010",
                    cl_fix_from_real(   4.0, (1, 3, -1)),
                    "cl_fix_from_real Wrong: Negative Fractional Bits");
                    
        -- *** cl_fix_to_real ***
        print("*** cl_fix_to_real ***");
        CheckReal(  3.0,
                    cl_fix_to_real(cl_fix_from_real(    3.0, (1, 3, 0)), (1, 3, 0)),
                    "cl_fix_to_real Wrong: Integer only, Signed, NoFractional Bits, Positive");
        CheckReal(  -3.0,
                    cl_fix_to_real(cl_fix_from_real(    -3.0, (1, 3, 0)), (1, 3, 0)),
                    "cl_fix_to_real Wrong: Integer only, Signed, NoFractional Bits, Negative");
        CheckReal(  3.0,
                    cl_fix_to_real(cl_fix_from_real(    3.0, (0, 3, 0)), (0, 3, 0)),
                    "cl_fix_to_real Wrong: Integer only, Unsigned, NoFractional Bits, Positive");
        CheckReal(  -3.25,
                    cl_fix_to_real(cl_fix_from_real(    -3.25, (1, 3, 2)), (1, 3, 2)),
                    "cl_fix_to_real Wrong: Integer and Fractional");
        CheckReal(  -3.0,
                    cl_fix_to_real(cl_fix_from_real(    -3.24, (1, 3, 1)), (1, 3, 1)),
                    "cl_fix_to_real Wrong: Rounding");
        CheckReal(  0.125,
                    cl_fix_to_real(cl_fix_from_real(    0.125, (0, -1, 3)), (0, -1, 3)),
                    "cl_fix_to_real Wrong: Negative Integer Bits");
        CheckReal(  4.0,
                    cl_fix_to_real(cl_fix_from_real(    4.0, (1, 3, -1)), (1, 3, -1)),
                    "cl_fix_to_real Wrong: Negative Fractional Bits");
                    
        -- *** cl_fix_from_bits_as_int ***
        print("*** cl_fix_from_bits_as_int ***");
        CheckStdlv("0011", cl_fix_from_bits_as_int(3, (0, 4, 0)), "cl_fix_from_bits_as_int: Unsigned Positive");
        CheckStdlv("0011", cl_fix_from_bits_as_int(3, (1, 3, 0)), "cl_fix_from_bits_as_int: Signed Positive");
        CheckStdlv("1101", cl_fix_from_bits_as_int(-3, (1, 3, 0)), "cl_fix_from_bits_as_int: Signed Negative");
        CheckStdlv("1101", cl_fix_from_bits_as_int(-3, (1, 1, 2)), "cl_fix_from_bits_as_int: Fractional"); -- binary point position is not important
        CheckStdlv("0001", cl_fix_from_bits_as_int(17, (0, 4, 0)), "cl_fix_from_bits_as_int: Wrap Unsigned");
        
        -- *** cl_fix_get_bits_as_int ***
        print("*** cl_fix_get_bits_as_int ***");
        CheckInt(3, cl_fix_get_bits_as_int("11", (0,2,0)), "cl_fix_get_bits_as_int: Unsigned Positive");
        CheckInt(3, cl_fix_get_bits_as_int("011", (1,2,0)), "cl_fix_get_bits_as_int: Signed Positive");
        CheckInt(-3, cl_fix_get_bits_as_int("1101", (1,3,0)), "cl_fix_get_bits_as_int: Signed Negative");
        CheckInt(-3, cl_fix_get_bits_as_int("1101", (1,1,2)), "cl_fix_get_bits_as_int: Fractional"); -- binary point position is not important
        
        -- *** cl_fix_resize ***
        print("*** cl_fix_resize ***");
        CheckStdlv( "0101", cl_fix_resize("0101", (1, 2, 1), (1, 2, 1)),
                    "cl_fix_resize: No formatchange");
                    
        CheckStdlv( "010", cl_fix_resize("0101", (1, 2, 1), (1, 2, 0), Trunc_s),
                    "cl_fix_resize: Remove Frac Bit 1 Trunc");
        CheckStdlv( "011", cl_fix_resize("0101", (1, 2, 1), (1, 2, 0), NonSymPos_s),
                    "cl_fix_resize: Remove Frac Bit 1 Round");
        CheckStdlv( "010", cl_fix_resize("0100", (1, 2, 1), (1, 2, 0), Trunc_s),
                    "cl_fix_resize: Remove Frac Bit 0 Trunc");
        CheckStdlv( "010", cl_fix_resize("0100", (1, 2, 1), (1, 2, 0), NonSymPos_s),
                    "cl_fix_resize: Remove Frac Bit 0 Round");
                    
        CheckStdlv( "01000", cl_fix_resize("0100", (1, 2, 1), (1, 2, 2), NonSymPos_s),
                    "cl_fix_resize: Add Fractional Bit Signed");
        CheckStdlv( "1000", cl_fix_resize("100", (0, 2, 1), (0, 2, 2), NonSymPos_s),
                    "cl_fix_resize: Add Fractional Bit Unsigned");
                    
        CheckStdlv( "0111", cl_fix_resize("00111", (1, 3, 1), (1, 2, 1), Trunc_s, None_s),
                    "cl_fix_resize: Remove Integer Bit, Signed, NoSat, Positive");
        CheckStdlv( "1001", cl_fix_resize("11001", (1, 3, 1), (1, 2, 1), Trunc_s, Sat_s),
                    "cl_fix_resize: Remove Integer Bit, Signed, NoSat, Negative");
        CheckStdlv( "1011", cl_fix_resize("01011", (1, 3, 1), (1, 2, 1), Trunc_s, None_s),
                    "cl_fix_resize: Remove Integer Bit, Signed, Wrap, Positive");
        CheckStdlv( "0011", cl_fix_resize("10011", (1, 3, 1), (1, 2, 1), Trunc_s, None_s),
                    "cl_fix_resize: Remove Integer Bit, Signed, Wrap, Negative");
        CheckStdlv( "0111", cl_fix_resize("01011", (1, 3, 1), (1, 2, 1), Trunc_s, Sat_s),
                    "cl_fix_resize: Remove Integer Bit, Signed, Sat, Positive");
        CheckStdlv( "1000", cl_fix_resize("10011", (1, 3, 1), (1, 2, 1), Trunc_s, Sat_s),
                    "cl_fix_resize: Remove Integer Bit, Signed, Sat, Negative");
                    
        CheckStdlv( "111", cl_fix_resize("0111", (0, 3, 1), (0, 2, 1), Trunc_s, None_s),
                    "cl_fix_resize: Remove Integer Bit, Unsigned, NoSat, Positive");
        CheckStdlv( "011", cl_fix_resize("1011", (0, 3, 1), (0, 2, 1), Trunc_s, None_s),
                    "cl_fix_resize: Remove Integer Bit, Unsigned, Wrap, Positive");
        CheckStdlv( "111", cl_fix_resize("1011", (0, 3, 1), (0, 2, 1), Trunc_s, Sat_s),
                    "cl_fix_resize: Remove Integer Bit, Unsigned, Sat, Positive");
                    
        CheckStdlv( "0111", cl_fix_resize("00111", (1, 3, 1), (0, 3, 1), Trunc_s, None_s),
                    "cl_fix_resize: Remove Sign Bit, Signed, NoSat, Positive");
        CheckStdlv( "0011", cl_fix_resize("10011", (1, 3, 1), (0, 3, 1), Trunc_s, None_s),
                    "cl_fix_resize: Remove Sign Bit, Signed, Wrap, Negative");
        CheckStdlv( "0000", cl_fix_resize("10011", (1, 3, 1), (0, 3, 1), Trunc_s, Sat_s),
                    "cl_fix_resize: Remove Sign Bit, Signed, Sat, Negative");
                    
        CheckStdlv( "1000", cl_fix_resize("01111", (1, 3, 1), (1, 3, 0), NonSymPos_s, None_s),
                    "cl_fix_resize: Overflow due rounding, Signed, Wrap");
        CheckStdlv( "0111", cl_fix_resize("01111", (1, 3, 1), (1, 3, 0), NonSymPos_s, Sat_s),
                    "cl_fix_resize: Overflow due rounding, Signed, Sat");
        CheckStdlv( "000", cl_fix_resize("1111", (0, 3, 1), (0, 3, 0), NonSymPos_s, None_s),
                    "cl_fix_resize: Overflow due rounding, Unsigned, Wrap");
        CheckStdlv( "111", cl_fix_resize("1111", (0, 3, 1), (0, 3, 0), NonSymPos_s, Sat_s),
                    "cl_fix_resize: Overflow due rounding, Unsigned, Sat");
                    
        CheckStdlv( "1111", cl_fix_resize("11111", (1, 3, 1), (1, 3, 0), NonSymNeg_s, None_s),
                    "cl_fix_resize: NonSymNeg_s -0.5");
        CheckStdlv( "1110", cl_fix_resize("11101", (1, 3, 1), (1, 3, 0), NonSymNeg_s, None_s),
                    "cl_fix_resize: NonSymNeg_s -1.5");
        CheckStdlv( "0000", cl_fix_resize("00001", (1, 3, 1), (1, 3, 0), NonSymNeg_s, None_s),
                    "cl_fix_resize: NonSymNeg_s 0.5");
        CheckStdlv( "0001", cl_fix_resize("00011", (1, 3, 1), (1, 3, 0), NonSymNeg_s, None_s),
                    "cl_fix_resize: NonSymNeg_s 1.5");
        CheckStdlv( "0010", cl_fix_resize("000111", (1, 3, 2), (1, 3, 0), NonSymNeg_s, None_s),
                    "cl_fix_resize: NonSymNeg_s 1.75");
                    
        CheckStdlv( "1111", cl_fix_resize("11111", (1, 3, 1), (1, 3, 0), SymInf_s, None_s),
                    "cl_fix_resize: SymInf_s -0.5");
        CheckStdlv( "1110", cl_fix_resize("11101", (1, 3, 1), (1, 3, 0), SymInf_s, None_s),
                    "cl_fix_resize: SymInf_s -1.5");
        CheckStdlv( "0001", cl_fix_resize("00001", (1, 3, 1), (1, 3, 0), SymInf_s, None_s),
                    "cl_fix_resize: SymInf_s 0.5");
        CheckStdlv( "0010", cl_fix_resize("00011", (1, 3, 1), (1, 3, 0), SymInf_s, None_s),
                    "cl_fix_resize: SymInf_s 1.5");
        CheckStdlv( "0010", cl_fix_resize("000111", (1, 3, 2), (1, 3, 0), SymInf_s, None_s),
                    "cl_fix_resize: SymInf_s 1.75");
                    
        CheckStdlv( "0000", cl_fix_resize("11111", (1, 3, 1), (1, 3, 0), SymZero_s, None_s),
                    "cl_fix_resize: SymZero_s -0.5");
        CheckStdlv( "1111", cl_fix_resize("11101", (1, 3, 1), (1, 3, 0), SymZero_s, None_s),
                    "cl_fix_resize: SymZero_s -1.5");
        CheckStdlv( "0000", cl_fix_resize("00001", (1, 3, 1), (1, 3, 0), SymZero_s, None_s),
                    "cl_fix_resize: SymZero_s 0.5");
        CheckStdlv( "0001", cl_fix_resize("00011", (1, 3, 1), (1, 3, 0), SymZero_s, None_s),
                    "cl_fix_resize: SymZero_s 1.5");
        CheckStdlv( "0010", cl_fix_resize("000111", (1, 3, 2), (1, 3, 0), SymZero_s, None_s),
                    "cl_fix_resize: SymZero_s 1.75");
                    
        CheckStdlv( "0000", cl_fix_resize("11111", (1, 3, 1), (1, 3, 0), ConvEven_s, None_s),
                    "cl_fix_resize: ConvEven_s -0.5");
        CheckStdlv( "1110", cl_fix_resize("11101", (1, 3, 1), (1, 3, 0), ConvEven_s, None_s),
                    "cl_fix_resize: ConvEven_s -1.5");
        CheckStdlv( "0000", cl_fix_resize("00001", (1, 3, 1), (1, 3, 0), ConvEven_s, None_s),
                    "cl_fix_resize: ConvEven_s 0.5");
        CheckStdlv( "0010", cl_fix_resize("00011", (1, 3, 1), (1, 3, 0), ConvEven_s, None_s),
                    "cl_fix_resize: ConvEven_s 1.5");
        CheckStdlv( "0010", cl_fix_resize("000111", (1, 3, 2), (1, 3, 0), ConvEven_s, None_s),
                    "cl_fix_resize: ConvEven_s 1.75");
                    
        CheckStdlv( "1111", cl_fix_resize("11111", (1, 3, 1), (1, 3, 0), ConvOdd_s, None_s),
                    "cl_fix_resize: ConvOdd_s -0.5");
        CheckStdlv( "1111", cl_fix_resize("11101", (1, 3, 1), (1, 3, 0), ConvOdd_s, None_s),
                    "cl_fix_resize: ConvOdd_s -1.5");
        CheckStdlv( "0001", cl_fix_resize("00001", (1, 3, 1), (1, 3, 0), ConvOdd_s, None_s),
                    "cl_fix_resize: ConvOdd_s 0.5");
        CheckStdlv( "0001", cl_fix_resize("00011", (1, 3, 1), (1, 3, 0), ConvOdd_s, None_s),
                    "cl_fix_resize: ConvOdd_s 1.5");
        CheckStdlv( "0010", cl_fix_resize("000111", (1, 3, 2), (1, 3, 0), ConvOdd_s, None_s),
                    "cl_fix_resize: ConvOdd_s 1.75");
                    
        -- error cases
        CheckStdlv( "0000101000", cl_fix_resize(cl_fix_from_real(2.5, (0, 5, 4)), (0, 5, 4), (0, 6, 4)),
                    "cl_fix_resize: Overflow due rounding, Unsigned, Sat");
        CheckStdlv( "000010100", cl_fix_resize(cl_fix_from_real(1.25, (0, 5, 3)), (0, 5, 3), (0, 5, 4)),
                    "cl_fix_resize: Overflow due rounding, Unsigned, Sat");
                    
        -- *** cl_fix_add ***
        print("*** cl_fix_add ***");
        CheckStdlv( cl_fix_from_real(-2.5+1.25, (1, 5, 3)),
                    cl_fix_add( cl_fix_from_real(-2.5, (1, 5, 3)), (1, 5, 3),
                                cl_fix_from_real(1.25, (1, 5, 3)), (1, 5, 3),
                                (1, 5, 3)),
                    "cl_fix_add: Same Fmt Signed");
        CheckStdlv( cl_fix_from_real(2.5+1.25, (0, 5, 3)),
                    cl_fix_add( cl_fix_from_real(2.5, (0, 5, 3)), (0, 5, 3),
                                cl_fix_from_real(1.25, (0, 5, 3)), (0, 5, 3),
                                (0, 5, 3)),
                    "cl_fix_add: Same Fmt Usigned");
        CheckStdlv( cl_fix_from_real(-2.5+1.25, (1, 5, 3)),
                    cl_fix_add( cl_fix_from_real(-2.5, (1, 6, 3)), (1, 6, 3),
                                cl_fix_from_real(1.25, (1, 5, 3)), (1, 5, 3),
                                (1, 5, 3)),
                    "cl_fix_add: Different Int Bits Signed");
        CheckStdlv( cl_fix_from_real(2.5+1.25, (0, 5, 3)),
                    cl_fix_add( cl_fix_from_real(2.5, (0, 6, 3)), (0, 6, 3),
                                cl_fix_from_real(1.25, (0, 5, 3)), (0, 5, 3),
                                (0, 5, 3)),
                    "cl_fix_add: Different Int Bits Usigned");
        CheckStdlv( cl_fix_from_real(-2.5+1.25, (1, 5, 3)),
                    cl_fix_add( cl_fix_from_real(-2.5, (1, 5, 4)), (1, 5, 4),
                                cl_fix_from_real(1.25, (1, 5, 3)), (1, 5, 3),
                                (1, 5, 3)),
                    "cl_fix_add: Different Frac Bits Signed");
        CheckStdlv( cl_fix_from_real(2.5+1.25, (0, 5, 3)),
                    cl_fix_add( cl_fix_from_real(2.5, (0, 5, 4)), (0, 5, 4),
                                cl_fix_from_real(1.25, (0, 5, 3)), (0, 5, 3),
                                (0, 5, 3)),
                    "cl_fix_add: Different Frac Bits Usigned");
        CheckStdlv( cl_fix_from_real(0.75+4.0, (0, 5, 5)),
                    cl_fix_add( cl_fix_from_real(0.75, (0, 0, 4)), (0, 0, 4),
                                cl_fix_from_real(4.0, (0, 4, -1)), (0, 4, -1),
                                (0, 5, 5)),
                    "cl_fix_add: Different Ranges Unsigned");
        CheckStdlv( cl_fix_from_real(5.0, (0, 5, 0)),
                    cl_fix_add( cl_fix_from_real(0.75, (0, 0, 4)), (0, 0, 4),
                                cl_fix_from_real(4.0, (0, 4, -1)), (0, 4, -1),
                                (0, 5, 0), NonSymPos_s),
                    "cl_fix_add: Round");
        CheckStdlv( cl_fix_from_real(15.0, (0, 4, 0)),
                    cl_fix_add( cl_fix_from_real(0.75, (0, 0, 4)), (0, 0, 4),
                                cl_fix_from_real(15.0, (0, 4, 0)), (0, 4, 0),
                                (0, 4, 0), NonSymPos_s, Sat_s),
                    "cl_fix_add: Satturate");
                    
        -- *** cl_fix_sub ***
        print("*** cl_fix_sub ***");
        CheckStdlv( cl_fix_from_real(-2.5-1.25, (1, 5, 3)),
                    cl_fix_sub( cl_fix_from_real(-2.5, (1, 5, 3)), (1, 5, 3),
                                cl_fix_from_real(1.25, (1, 5, 3)), (1, 5, 3),
                                (1, 5, 3)),
                    "cl_fix_sub: Same Fmt Signed");
        CheckStdlv( cl_fix_from_real(2.5-1.25, (0, 5, 3)),
                    cl_fix_sub( cl_fix_from_real(2.5, (0, 5, 3)), (0, 5, 3),
                                cl_fix_from_real(1.25, (0, 5, 3)), (0, 5, 3),
                                (0, 5, 3)),
                    "cl_fix_sub: Same Fmt Usigned");
        CheckStdlv( cl_fix_from_real(-2.5-1.25, (1, 5, 3)),
                    cl_fix_sub( cl_fix_from_real(-2.5, (1, 6, 3)), (1, 6, 3),
                                cl_fix_from_real(1.25, (1, 5, 3)), (1, 5, 3),
                                (1, 5, 3)),
                    "cl_fix_sub: Different Int Bits Signed");
        CheckStdlv( cl_fix_from_real(2.5-1.25, (0, 5, 3)),
                    cl_fix_sub( cl_fix_from_real(2.5, (0, 6, 3)), (0, 6, 3),
                                cl_fix_from_real(1.25, (0, 5, 3)), (0, 5, 3),
                                (0, 5, 3)),
                    "cl_fix_sub: Different Int Bits Usigned");
        CheckStdlv( cl_fix_from_real(-2.5-1.25, (1, 5, 3)),
                    cl_fix_sub( cl_fix_from_real(-2.5, (1, 5, 4)), (1, 5, 4),
                                cl_fix_from_real(1.25, (1, 5, 3)), (1, 5, 3),
                                (1, 5, 3)),
                    "cl_fix_sub: Different Frac Bits Signed");
        CheckStdlv( cl_fix_from_real(2.5-1.25, (0, 5, 3)),
                    cl_fix_sub( cl_fix_from_real(2.5, (0, 5, 4)), (0, 5, 4),
                                cl_fix_from_real(1.25, (0, 5, 3)), (0, 5, 3),
                                (0, 5, 3)),
                    "cl_fix_sub: Different Frac Bits Usigned");
        CheckStdlv( cl_fix_from_real(4.0-0.75, (0, 5, 5)),
                    cl_fix_sub( cl_fix_from_real(4.0, (0, 4, -1)), (0, 4, -1),
                                cl_fix_from_real(0.75, (0, 0, 4)), (0, 0, 4),
                                (0, 5, 5)),
                    "cl_fix_sub: Different Ranges Unsigned");
        CheckStdlv( cl_fix_from_real(4.0, (0, 5, 0)),
                    cl_fix_sub( cl_fix_from_real(4.0, (0, 4, -1)), (0, 4, -1),
                                cl_fix_from_real(0.25, (0, 0, 4)), (0, 0, 4),
                                (0, 5, 0), NonSymPos_s),
                    "cl_fix_sub: Round");
        CheckStdlv( cl_fix_from_real(0.0, (0, 4, 0)),
                    cl_fix_sub( cl_fix_from_real(0.75, (0, 0, 4)), (0, 0, 4),
                                cl_fix_from_real(5.0, (0, 4, 0)), (0, 4, 0),
                                (0, 4, 0), NonSymPos_s, Sat_s),
                    "cl_fix_sub: Satturate");
        CheckStdlv( cl_fix_from_real(-16.0, (1, 4, 0)),
                    cl_fix_sub( cl_fix_from_real(0.0, (1, 4, 0)), (1, 4, 0),
                                cl_fix_from_real(-16.0, (1, 4, 0)), (1, 4, 0),
                                (1, 4, 0), NonSymPos_s, None_s),
                    "cl_fix_sub: Invert most negative signed, noSat");
        CheckStdlv( cl_fix_from_real(15.0, (1, 4, 0)),
                    cl_fix_sub( cl_fix_from_real(0.0, (1, 4, 0)), (1, 4, 0),
                                cl_fix_from_real(-16.0, (1, 4, 0)), (1, 4, 0),
                                (1, 4, 0), NonSymPos_s, Sat_s),
                    "cl_fix_sub: Invert most negative signed, Sat");
        CheckStdlv( cl_fix_from_real(1.0, (0, 4, 0)),
                    cl_fix_sub( cl_fix_from_real(0.0, (0, 4, 0)), (0, 4, 0),
                                cl_fix_from_real(15.0, (0, 4, 0)), (0, 4, 0),
                                (0, 4, 0), NonSymPos_s, None_s),
                    "cl_fix_sub: Invert most negative unsigned, noSat");
        CheckStdlv( cl_fix_from_real(0.0, (0, 4, 0)),
                    cl_fix_sub( cl_fix_from_real(0.0, (0, 4, 0)), (0, 4, 0),
                                cl_fix_from_real(15.0, (0, 4, 0)), (0, 4, 0),
                                (0, 4, 0), NonSymPos_s, Sat_s),
                    "cl_fix_sub: Invert unsigned, Sat");
                    
        -- *** cl_fix_mult ***
        print("*** cl_fix_mult ***");
        CheckStdlv( cl_fix_from_real(2.5*1.25, (0, 5, 5)),
                    cl_fix_mult(    cl_fix_from_real(2.5, (0, 5, 1)), (0, 5, 1),
                                cl_fix_from_real(1.25, (0, 5, 2)), (0, 5, 2),
                                (0, 5, 5)),
                    "cl_fix_mult: A unsigned positive, B unsigned positive");
        CheckStdlv( cl_fix_from_real(2.5*1.25, (1, 3, 3)),
                    cl_fix_mult(    cl_fix_from_real(2.5, (1, 2, 1)), (1, 2, 1),
                                cl_fix_from_real(1.25, (1, 1, 2)), (1, 1, 2),
                                (1, 3, 3)),
                    "cl_fix_mult: A signed positive, B signed positive");
        CheckStdlv( cl_fix_from_real(2.5*(-1.25), (1, 3, 3)),
                    cl_fix_mult(    cl_fix_from_real(2.5, (1, 2, 1)), (1, 2, 1),
                                cl_fix_from_real(-1.25, (1, 1, 2)), (1, 1, 2),
                                (1, 3, 3)),
                    "cl_fix_mult: A signed positive, B signed negative");
        CheckStdlv( cl_fix_from_real((-2.5)*1.25, (1, 3, 3)),
                    cl_fix_mult(    cl_fix_from_real(-2.5, (1, 2, 1)), (1, 2, 1),
                                cl_fix_from_real(1.25, (1, 1, 2)), (1, 1, 2),
                                (1, 3, 3)),
                    "cl_fix_mult: A signed negative, B signed positive");
        CheckStdlv( cl_fix_from_real((-2.5)*(-1.25), (1, 3, 3)),
                    cl_fix_mult(    cl_fix_from_real(-2.5, (1, 2, 1)), (1, 2, 1),
                                cl_fix_from_real(-1.25, (1, 1, 2)), (1, 1, 2),
                                (1, 3, 3)),
                    "cl_fix_mult: A signed negative, B signed negative");
        CheckStdlv( cl_fix_from_real(2.5*1.25, (1, 3, 3)),
                    cl_fix_mult(    cl_fix_from_real(2.5, (0, 2, 1)), (0, 2, 1),
                                cl_fix_from_real(1.25, (1, 1, 2)), (1, 1, 2),
                                (1, 3, 3)),
                    "cl_fix_mult: A unsigned positive, B signed positive");
        CheckStdlv( cl_fix_from_real(2.5*(-1.25), (1, 3, 3)),
                    cl_fix_mult(    cl_fix_from_real(2.5, (0, 2, 1)), (0, 2, 1),
                                cl_fix_from_real(-1.25, (1, 1, 2)), (1, 1, 2),
                                (1, 3, 3)),
                    "cl_fix_mult: A unsigned positive, B signed negative");
        CheckStdlv( cl_fix_from_real(2.5*1.25, (0, 3, 3)),
                    cl_fix_mult(    cl_fix_from_real(2.5, (0, 2, 1)), (0, 2, 1),
                                cl_fix_from_real(1.25, (1, 1, 2)), (1, 1, 2),
                                (0, 3, 3)),
                    "cl_fix_mult: A unsigned positive, B signed positive, result unsigned");
        CheckStdlv( cl_fix_from_real(1.875, (0, 1, 3)),
                    cl_fix_mult(    cl_fix_from_real(2.5, (0, 2, 1)), (0, 2, 1),
                                cl_fix_from_real(1.25, (1, 1, 2)), (1, 1, 2),
                                (0, 1, 3), Trunc_s, Sat_s),
                    "cl_fix_mult: A unsigned positive, B signed positive, saturate");
                    
        -- *** cl_fix_abs ***
        print("*** cl_fix_abs ***");
        CheckStdlv( cl_fix_from_real(2.5, (0, 5, 5)),
                    cl_fix_abs( cl_fix_from_real(2.5, (0, 5, 1)), (0, 5, 1),
                                (0, 5, 5)),
                    "cl_fix_abs: positive stay positive");
        CheckStdlv( cl_fix_from_real(4.0, (1, 3, 3)),
                    cl_fix_abs( cl_fix_from_real(-4.0, (1, 2, 2)), (1, 2, 2),
                                (1, 3, 3)),
                    "cl_fix_abs: negative becomes positive");
        CheckStdlv( cl_fix_from_real(3.75, (1, 2, 2)),
                    cl_fix_abs( cl_fix_from_real(-4.0, (1, 2, 2)), (1, 2, 2),
                                (1, 2, 2), Trunc_s, Sat_s),
                    "cl_fix_abs: most negative value sat");
                    
        -- *** cl_fix_neg ***
        print("*** cl_fix_neg ***");
        CheckStdlv( cl_fix_from_real(-2.5, (1, 5, 5)),
                    cl_fix_neg( cl_fix_from_real(2.5, (1, 5, 1)), (1, 5, 1),
                                (1, 5, 5)),
                    "cl_fix_neg: positive to negative (signed -> signed)");
        CheckStdlv( cl_fix_from_real(-2.5, (1, 5, 5)),
                    cl_fix_neg( cl_fix_from_real(2.5, (0, 5, 1)), (0, 5, 1),
                                (1, 5, 5)),
                    "cl_fix_neg: positive to negative (unsigned -> signed)");
        CheckStdlv( cl_fix_from_real(2.5, (1, 5, 5)),
                    cl_fix_neg( cl_fix_from_real(-2.5, (1, 5, 1)), (1, 5, 1),
                                (1, 5, 5)),
                    "cl_fix_neg: negative to positive (signed -> signed)");
        CheckStdlv( cl_fix_from_real(2.5, (0, 5, 5)),
                    cl_fix_neg( cl_fix_from_real(-2.5, (1, 5, 1)), (1, 5, 1),
                                (0, 5, 5)),
                    "cl_fix_neg: negative to positive (signed -> unsigned)");
        CheckStdlv( cl_fix_from_real(3.75, (1, 2, 2)),
                    cl_fix_neg( cl_fix_from_real(-4.0, (1, 2, 4)), (1, 2, 4),
                                (1, 2, 2), Trunc_s, Sat_s),
                    "cl_fix_neg: saturation (signed -> signed)");
        CheckStdlv( cl_fix_from_real(-4.0, (1, 2, 2)),
                    cl_fix_neg( cl_fix_from_real(-4.0, (1, 2, 4)), (1, 2, 4),
                                (1, 2, 2), Trunc_s, None_s),
                    "cl_fix_neg: wrap (signed -> signed)");
        CheckStdlv( cl_fix_from_real(0.0, (0, 5, 5)),
                    cl_fix_neg( cl_fix_from_real(2.5, (1, 5, 1)), (1, 5, 1),
                                (0, 5, 5), Trunc_s, Sat_s),
                    "cl_fix_neg: positive to negative saturate (signed -> unsigned)");
                    
        -- *** cl_fix_shift left***
        print("*** cl_fix_shift left ***");
        CheckStdlv( cl_fix_from_real(2.5, (0, 3, 2)),
                    cl_fix_shift(   cl_fix_from_real(1.25, (0, 3, 2)),  (0, 3, 2),
                                    1,
                                    (0, 3, 2)),
                                    "Shift same format unsigned");
        CheckStdlv( cl_fix_from_real(2.5, (1, 3, 2)),
                    cl_fix_shift(   cl_fix_from_real(1.25, (1, 3, 2)),   (1, 3, 2),
                                    1,
                                    (1, 3, 2)),
                                    "Shift same format signed");
        CheckStdlv( cl_fix_from_real(2.5, (0, 3, 2)),
                    cl_fix_shift(   cl_fix_from_real(1.25, (1, 1, 2)),   (1, 1, 2),
                                    1,
                                    (0, 3, 2)),
                                    "Shift format change");
        CheckStdlv( cl_fix_from_real(3.75, (1, 2, 2)),
                    cl_fix_shift(   cl_fix_from_real(2.0, (1, 2, 2)),    (1, 2, 2),
                                    1,
                                    (1, 2, 2), Trunc_s, Sat_s),
                                    "saturation signed");
        CheckStdlv( cl_fix_from_real(3.75, (1, 2, 2)),
                    cl_fix_shift(   cl_fix_from_real(2.0, (0, 3, 2)),   (0, 3, 2),
                                    1,
                                    (1, 2, 2), Trunc_s, Sat_s),
                                    "saturation unsigned to signed");
        CheckStdlv( cl_fix_from_real(0.0, (0, 2, 2)),
                    cl_fix_shift(   cl_fix_from_real(-0.5, (1, 3, 2)),   (1, 3, 2),
                                    1,
                                    (0, 2, 2), Trunc_s, Sat_s),
                                    "saturation signed to unsigned");
        CheckStdlv( cl_fix_from_real(-4.0, (1, 2, 2)),
                    cl_fix_shift(   cl_fix_from_real(2.0, (1, 2, 2)),    (1, 2, 2),
                                    1,
                                    (1, 2, 2), Trunc_s, None_s),
                                    "wrap signed");
        CheckStdlv( cl_fix_from_real(-4.0, (1, 2, 2)),
                    cl_fix_shift(   cl_fix_from_real(2.0, (0, 3, 2)),   (0, 3, 2),
                                    1,
                                    (1, 2, 2), Trunc_s, None_s),
                                    "wrap unsigned to signed");
        CheckStdlv( cl_fix_from_real(3.0, (0, 2, 2)),
                    cl_fix_shift(   cl_fix_from_real(-0.5, (1, 3, 2)), (1, 3, 2),
                                    1,
                                    (0, 2, 2), Trunc_s, None_s),
                                    "wrap signed to unsigned");
        CheckStdlv( cl_fix_from_real(0.5, (1, 5, 5)),
                    cl_fix_shift(   cl_fix_from_real(0.5, (1, 5, 5)), (1, 5, 5),
                                    0,
                                    (1, 5, 5), Trunc_s, None_s),
                                    "shift 0");
        CheckStdlv( cl_fix_from_real(-4.0, (1, 5, 5)),
                    cl_fix_shift(   cl_fix_from_real(-0.5, (1, 5, 5)), (1, 5, 5),
                                    3,
                                    (1, 5, 5), Trunc_s, None_s),
                                    "shift 3");
                                    
        -- *** cl_fix_shift right ***
        print("*** cl_fix_shift right  ***");
        CheckStdlv( cl_fix_from_real(1.25, (0, 3, 2)),
                    cl_fix_shift(   cl_fix_from_real(2.5, (0, 3, 2)),   (0, 3, 2),
                                    -1,
                                    (0, 3, 2)),
                                    "Shift same format unsigned");
        CheckStdlv( cl_fix_from_real(1.25, (1, 3, 2)),
                    cl_fix_shift(   cl_fix_from_real(2.5, (1, 3, 2)),    (1, 3, 2),
                                    -1,
                                    (1, 3, 2)),
                                    "Shift same format signed");
        CheckStdlv( cl_fix_from_real(1.25, (1, 1, 2)),
                    cl_fix_shift(   cl_fix_from_real(2.5, (0, 3, 2)),   (0, 3, 2),
                                    -1,
                                    (1, 1, 2)),
                                    "Shift format change");
        CheckStdlv( cl_fix_from_real(0.0, (0, 2, 2)),
                    cl_fix_shift(   cl_fix_from_real(-0.5, (1, 3, 2)),   (1, 3, 2),
                                    -1,
                                    (0, 2, 2), Trunc_s, Sat_s),
                                    "saturation signed to unsigned");
        CheckStdlv( cl_fix_from_real(0.5, (1, 5, 5)),
                    cl_fix_shift(   cl_fix_from_real(0.5, (1, 5, 5)), (1, 5, 5),
                                    0,
                                    (1, 5, 5), Trunc_s, None_s),
                                    "shift 0");
        CheckStdlv( cl_fix_from_real(-0.5, (1, 5, 5)),
                    cl_fix_shift(   cl_fix_from_real(-4.0, (1, 5, 5)), (1, 5, 5),
                                    -3,
                                    (1, 5, 5), Trunc_s, None_s),
                                    "shift 3");
                                    
        -- *** cl_fix_max_value ***
        print("*** cl_fix_max_value ***");
        CheckStdlv( "1111", cl_fix_max_value((0,2,2)), "unsigned");
        CheckStdlv( "0111", cl_fix_max_value((1,1,2)), "signed");
        
        -- *** cl_fix_min_value ***
        print("*** cl_fix_min_value ***");
        CheckStdlv( "0000", cl_fix_min_value((0,2,2)), "unsigned");
        CheckStdlv( "1000", cl_fix_min_value((1,1,2)), "signed");
        
        -- *** cl_fix_in_range ***
        print("*** cl_fix_in_range ***");
        CheckBoolean(   true,
                        cl_fix_in_range(cl_fix_from_real(1.25, (1, 4, 2)), (1, 4, 2),
                                        (1, 2, 4), Trunc_s),
                        "In Range Normal");
        CheckBoolean(   false,
                        cl_fix_in_range(cl_fix_from_real(6.25, (1, 4, 2)), (1, 4, 2),
                                        (1, 2, 4), Trunc_s),
                        "Out Range Normal");
        CheckBoolean(   false,
                        cl_fix_in_range(cl_fix_from_real(-1.25, (1, 4, 2)), (1, 4, 2),
                                        (0, 5, 2), Trunc_s),
                        "signed -> unsigned OOR");
        CheckBoolean(   false,
                        cl_fix_in_range(cl_fix_from_real(15.0, (0, 4, 2)), (0, 4, 2),
                                        (1, 3, 2), Trunc_s),
                        "unsigned -> signed OOR");
        CheckBoolean(   true,
                        cl_fix_in_range(cl_fix_from_real(15.0, (0, 4, 2)), (0, 4, 2),
                                        (1, 4, 2), Trunc_s),
                        "unsigned -> signed OK");
        CheckBoolean(   false,
                        cl_fix_in_range(cl_fix_from_real(15.5, (0, 4, 2)), (0, 4, 2),
                                        (1, 4, 0), NonSymPos_s),
                        "rounding OOR");
        CheckBoolean(   true,
                        cl_fix_in_range(cl_fix_from_real(15.5, (0, 4, 2)), (0, 4, 2),
                                        (1, 4, 1), NonSymPos_s),
                        "rounding OK 1");
        CheckBoolean(   true,
                        cl_fix_in_range(cl_fix_from_real(15.5, (0, 4, 2)), (0, 4, 2),
                                        (0, 5, 0), NonSymPos_s),
                        "rounding OK 2");
                        
        -- *** cl_fix_compare ***
        print("*** cl_fix_compare ***");
        CheckBoolean(   true,
                        cl_fix_compare( "a<b",
                                        cl_fix_from_real(1.25, (0, 4, 2)), (0, 4, 2),
                                        cl_fix_from_real(1.5, (0, 2, 1)), (0, 2, 1)),
                        "a<b unsigned unsigned true");
        CheckBoolean(   false,
                        cl_fix_compare( "a<b",
                                        cl_fix_from_real(1.5, (0, 4, 2)), (0, 4, 2),
                                        cl_fix_from_real(1.5, (0, 2, 1)), (0, 2, 1)),
                        "a<b unsigned unsigned false");
        CheckBoolean(   true,
                        cl_fix_compare( "a<b",
                                        cl_fix_from_real(1.25, (1, 4, 2)), (1, 4, 2),
                                        cl_fix_from_real(1.5, (0, 2, 1)), (0, 2, 1)),
                        "a<b signed unsigned true");
        CheckBoolean(   false,
                        cl_fix_compare( "a<b",
                                        cl_fix_from_real(2.5, (0, 4, 2)), (0, 4, 2),
                                        cl_fix_from_real(1.5, (1, 2, 1)), (1, 2, 1)),
                        "a<b unsigned signed false");
        CheckBoolean(   true,
                        cl_fix_compare( "a<b",
                                        cl_fix_from_real(-1.25, (1, 4, 2)), (1, 4, 2),
                                        cl_fix_from_real(-1.0, (1, 2, 1)), (1, 2, 1)),
                        "a<b signed signed true");
        CheckBoolean(   false,
                        cl_fix_compare( "a<b",
                                        cl_fix_from_real(-0.5, (1, 4, 2)), (1, 4, 2),
                                        cl_fix_from_real(-1.5, (1, 2, 1)), (1, 2, 1)),
                        "a<b signed signed false");
                        
        CheckBoolean(   true,
                        cl_fix_compare( "a=b",
                                        cl_fix_from_real(1.5, (1, 4, 2)), (1, 4, 2),
                                        cl_fix_from_real(1.5, (0, 2, 1)), (0, 2, 1)),
                        "a=b signed unsigned true");
        CheckBoolean(   false,
                        cl_fix_compare( "a=b",
                                        cl_fix_from_real(2.5, (0, 4, 2)), (0, 4, 2),
                                        cl_fix_from_real(-1.5, (1, 2, 1)), (1, 2, 1)),
                        "a=b unsigned signed false");
                        
        CheckBoolean(   true,
                        cl_fix_compare( "a>b",
                                        cl_fix_from_real(2.5, (1, 4, 2)), (1, 4, 2),
                                        cl_fix_from_real(1.5, (0, 2, 1)), (0, 2, 1)),
                        "a>b signed unsigned true");
        CheckBoolean(   false,
                        cl_fix_compare( "a>b",
                                        cl_fix_from_real(1.5, (0, 4, 2)), (0, 4, 2),
                                        cl_fix_from_real(1.5, (1, 2, 1)), (1, 2, 1)),
                        "a>b unsigned signed false");
                        
        CheckBoolean(   true,
                        cl_fix_compare( "a>=b",
                                        cl_fix_from_real(2.5, (1, 4, 2)), (1, 4, 2),
                                        cl_fix_from_real(1.5, (0, 2, 1)), (0, 2, 1)),
                        "a>=b signed unsigned true 1");
        CheckBoolean(   true,
                        cl_fix_compare( "a>=b",
                                        cl_fix_from_real(1.5, (1, 4, 2)), (1, 4, 2),
                                        cl_fix_from_real(1.5, (0, 2, 1)), (0, 2, 1)),
                        "a>=b signed unsigned true 2");
        CheckBoolean(   false,
                        cl_fix_compare( "a>=b",
                                        cl_fix_from_real(1.25, (0, 4, 2)), (0, 4, 2),
                                        cl_fix_from_real(1.5, (1, 2, 1)), (1, 2, 1)),
                        "a>=b unsigned signed false 1");
                        
        CheckBoolean(   true,
                        cl_fix_compare( "a<=b",
                                        cl_fix_from_real(-2.5, (1, 4, 2)), (1, 4, 2),
                                        cl_fix_from_real(1.5, (0, 2, 1)), (0, 2, 1)),
                        "a<=b signed unsigned true 1");
        CheckBoolean(   true,
                        cl_fix_compare( "a<=b",
                                        cl_fix_from_real(1.5, (1, 4, 2)), (1, 4, 2),
                                        cl_fix_from_real(1.5, (0, 2, 1)), (0, 2, 1)),
                        "a<=b signed unsigned true 2");
        CheckBoolean(   false,
                        cl_fix_compare( "a<=b",
                                        cl_fix_from_real(0.25, (0, 4, 2)), (0, 4, 2),
                                        cl_fix_from_real(-1.5, (1, 2, 1)), (1, 2, 1)),
                        "a<=b unsigned signed false 1");
                        
        CheckBoolean(   false,
                        cl_fix_compare( "a!=b",
                                        cl_fix_from_real(1.5, (1, 4, 2)), (1, 4, 2),
                                        cl_fix_from_real(1.5, (0, 2, 1)), (0, 2, 1)),
                        "a!=b signed unsigned false");
        CheckBoolean(   true,
                        cl_fix_compare( "a!=b",
                                        cl_fix_from_real(2.5, (0, 4, 2)), (0, 4, 2),
                                        cl_fix_from_real(-1.5, (1, 2, 1)), (1, 2, 1)),
                        "a!=b unsigned signed true");
                    
        -- *** cl_fix_addsub ***
        print("*** cl_fix_addsub ***");
        CheckStdlv( cl_fix_from_real(1.75, (1,3,3)),
                    cl_fix_addsub(  cl_fix_from_real(1.0, (1,3,3)), (1,3,3),
                                    cl_fix_from_real(0.75, (1,3,3)), (1,3,3), '1', (1,3,3)), "Add");
        CheckStdlv( cl_fix_from_real(1.0, (1,3,3)),
                    cl_fix_addsub(  cl_fix_from_real(1.25, (1,3,3)), (1,3,3),
                                    cl_fix_from_real(0.25, (1,3,3)), (1,3,3), '0', (1,3,3)), "Sub");
        wait;
    end process;
    
end sim;
