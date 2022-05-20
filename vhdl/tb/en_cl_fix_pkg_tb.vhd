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
        -- *** cl_fix_width ***
        print("*** cl_fix_width ***");
        CheckInt(3, cl_fix_width((false, 3, 0)),    "cl_fix_width Wrong: Integer only, Unsigned, NoFractional Bits");
        CheckInt(4, cl_fix_width((true, 3, 0)),     "cl_fix_width Wrong: Integer only, Signed, NoFractional Bits");
        CheckInt(3, cl_fix_width((false, 0, 3)),    "cl_fix_width Wrong: Fractional only, Unsigned, No Integer Bits");
        CheckInt(4, cl_fix_width((true, 0, 3)),     "cl_fix_width Wrong: Fractional only, Signed, No Integer Bits");
        CheckInt(7, cl_fix_width((true, 3, 3)),     "cl_fix_width Wrong: Integer and Fractional Bits");
        CheckInt(2, cl_fix_width((true, -2, 3)),    "cl_fix_width Wrong: Negative integer bits");
        CheckInt(2, cl_fix_width((true, 3, -2)),    "cl_fix_width Wrong: Negative fractional bits");
        
        -- *** cl_fix_from_real ***
        print("*** cl_fix_from_real ***");
        CheckStdlv( "0011",
                    cl_fix_from_real(   3.0, (true, 3, 0)),
                    "cl_fix_from_real Wrong: Integer only, Signed, NoFractional Bits, Positive");
        CheckStdlv( "1101",
                    cl_fix_from_real(   -3.0, (true, 3, 0)),
                    "cl_fix_from_real Wrong: Integer only, Signed, NoFractional Bits, Negative");
        CheckStdlv( "011",
                    cl_fix_from_real(   3.0, (false, 3, 0)),
                    "cl_fix_from_real Wrong: Integer only, Unsigned, NoFractional Bits, Positive");
        CheckStdlv( "110011",
                    cl_fix_from_real(   -3.25, (true, 3, 2)),
                    "cl_fix_from_real Wrong: Integer and Fractional");
        CheckStdlv( "11010",
                    cl_fix_from_real(   -3.24, (true, 3, 1)),
                    "cl_fix_from_real Wrong: Rounding");
        CheckStdlv( "01",
                    cl_fix_from_real(   0.125, (false, -1, 3)),
                    "cl_fix_from_real Wrong: Negative Integer Bits");
        CheckStdlv( "010",
                    cl_fix_from_real(   4.0, (true, 3, -1)),
                    "cl_fix_from_real Wrong: Negative Fractional Bits");
                    
        -- *** cl_fix_to_real ***
        print("*** cl_fix_to_real ***");
        CheckReal(  3.0,
                    cl_fix_to_real(cl_fix_from_real(    3.0, (true, 3, 0)), (true, 3, 0)),
                    "cl_fix_to_real Wrong: Integer only, Signed, NoFractional Bits, Positive");
        CheckReal(  -3.0,
                    cl_fix_to_real(cl_fix_from_real(    -3.0, (true, 3, 0)), (true, 3, 0)),
                    "cl_fix_to_real Wrong: Integer only, Signed, NoFractional Bits, Negative");
        CheckReal(  3.0,
                    cl_fix_to_real(cl_fix_from_real(    3.0, (false, 3, 0)), (false, 3, 0)),
                    "cl_fix_to_real Wrong: Integer only, Unsigned, NoFractional Bits, Positive");
        CheckReal(  -3.25,
                    cl_fix_to_real(cl_fix_from_real(    -3.25, (true, 3, 2)), (true, 3, 2)),
                    "cl_fix_to_real Wrong: Integer and Fractional");
        CheckReal(  -3.0,
                    cl_fix_to_real(cl_fix_from_real(    -3.24, (true, 3, 1)), (true, 3, 1)),
                    "cl_fix_to_real Wrong: Rounding");
        CheckReal(  0.125,
                    cl_fix_to_real(cl_fix_from_real(    0.125, (false, -1, 3)), (false, -1, 3)),
                    "cl_fix_to_real Wrong: Negative Integer Bits");
        CheckReal(  4.0,
                    cl_fix_to_real(cl_fix_from_real(    4.0, (true, 3, -1)), (true, 3, -1)),
                    "cl_fix_to_real Wrong: Negative Fractional Bits");
                    
        -- *** cl_fix_from_bits_as_int ***
        print("*** cl_fix_from_bits_as_int ***");
        CheckStdlv("0011", cl_fix_from_bits_as_int(3, (false, 4, 0)), "cl_fix_from_bits_as_int: Unsigned Positive");
        CheckStdlv("0011", cl_fix_from_bits_as_int(3, (true, 3, 0)), "cl_fix_from_bits_as_int: Signed Positive");
        CheckStdlv("1101", cl_fix_from_bits_as_int(-3, (true, 3, 0)), "cl_fix_from_bits_as_int: Signed Negative");
        CheckStdlv("1101", cl_fix_from_bits_as_int(-3, (true, 1, 2)), "cl_fix_from_bits_as_int: Fractional"); -- binary point position is not important
        CheckStdlv("0001", cl_fix_from_bits_as_int(17, (false, 4, 0)), "cl_fix_from_bits_as_int: Wrap Unsigned");
        
        -- *** cl_fix_get_bits_as_int ***
        print("*** cl_fix_get_bits_as_int ***");
        CheckInt(3, cl_fix_get_bits_as_int("11", (false,2,0)), "cl_fix_get_bits_as_int: Unsigned Positive");
        CheckInt(3, cl_fix_get_bits_as_int("011", (true,2,0)), "cl_fix_get_bits_as_int: Signed Positive");
        CheckInt(-3, cl_fix_get_bits_as_int("1101", (true,3,0)), "cl_fix_get_bits_as_int: Signed Negative");
        CheckInt(-3, cl_fix_get_bits_as_int("1101", (true,1,2)), "cl_fix_get_bits_as_int: Fractional"); -- binary point position is not important
        
        -- *** cl_fix_resize ***
        print("*** cl_fix_resize ***");
        CheckStdlv( "0101", cl_fix_resize("0101", (true, 2, 1), (true, 2, 1)),
                    "cl_fix_resize: No formatchange");
                    
        CheckStdlv( "010", cl_fix_resize("0101", (true, 2, 1), (true, 2, 0), Trunc_s),
                    "cl_fix_resize: Remove Frac Bit 1 Trunc");
        CheckStdlv( "011", cl_fix_resize("0101", (true, 2, 1), (true, 2, 0), Round_s),
                    "cl_fix_resize: Remove Frac Bit 1 Round");
        CheckStdlv( "010", cl_fix_resize("0100", (true, 2, 1), (true, 2, 0), Trunc_s),
                    "cl_fix_resize: Remove Frac Bit 0 Trunc");
        CheckStdlv( "010", cl_fix_resize("0100", (true, 2, 1), (true, 2, 0), Round_s),
                    "cl_fix_resize: Remove Frac Bit 0 Round");
                    
        CheckStdlv( "01000", cl_fix_resize("0100", (true, 2, 1), (true, 2, 2), Round_s),
                    "cl_fix_resize: Add Fractional Bit Signed");
        CheckStdlv( "1000", cl_fix_resize("100", (false, 2, 1), (false, 2, 2), Round_s),
                    "cl_fix_resize: Add Fractional Bit Unsigned");
                    
        CheckStdlv( "0111", cl_fix_resize("00111", (true, 3, 1), (true, 2, 1), Trunc_s, None_s),
                    "cl_fix_resize: Remove Integer Bit, Signed, NoSat, Positive");
        CheckStdlv( "1001", cl_fix_resize("11001", (true, 3, 1), (true, 2, 1), Trunc_s, Sat_s),
                    "cl_fix_resize: Remove Integer Bit, Signed, NoSat, Negative");
        CheckStdlv( "1011", cl_fix_resize("01011", (true, 3, 1), (true, 2, 1), Trunc_s, None_s),
                    "cl_fix_resize: Remove Integer Bit, Signed, Wrap, Positive");
        CheckStdlv( "0011", cl_fix_resize("10011", (true, 3, 1), (true, 2, 1), Trunc_s, None_s),
                    "cl_fix_resize: Remove Integer Bit, Signed, Wrap, Negative");
        CheckStdlv( "0111", cl_fix_resize("01011", (true, 3, 1), (true, 2, 1), Trunc_s, Sat_s),
                    "cl_fix_resize: Remove Integer Bit, Signed, Sat, Positive");
        CheckStdlv( "1000", cl_fix_resize("10011", (true, 3, 1), (true, 2, 1), Trunc_s, Sat_s),
                    "cl_fix_resize: Remove Integer Bit, Signed, Sat, Negative");
                    
        CheckStdlv( "111", cl_fix_resize("0111", (false, 3, 1), (false, 2, 1), Trunc_s, None_s),
                    "cl_fix_resize: Remove Integer Bit, Unsigned, NoSat, Positive");
        CheckStdlv( "011", cl_fix_resize("1011", (false, 3, 1), (false, 2, 1), Trunc_s, None_s),
                    "cl_fix_resize: Remove Integer Bit, Unsigned, Wrap, Positive");
        CheckStdlv( "111", cl_fix_resize("1011", (false, 3, 1), (false, 2, 1), Trunc_s, Sat_s),
                    "cl_fix_resize: Remove Integer Bit, Unsigned, Sat, Positive");
                    
        CheckStdlv( "0111", cl_fix_resize("00111", (true, 3, 1), (false, 3, 1), Trunc_s, None_s),
                    "cl_fix_resize: Remove Sign Bit, Signed, NoSat, Positive");
        CheckStdlv( "0011", cl_fix_resize("10011", (true, 3, 1), (false, 3, 1), Trunc_s, None_s),
                    "cl_fix_resize: Remove Sign Bit, Signed, Wrap, Negative");
        CheckStdlv( "0000", cl_fix_resize("10011", (true, 3, 1), (false, 3, 1), Trunc_s, Sat_s),
                    "cl_fix_resize: Remove Sign Bit, Signed, Sat, Negative");
                    
        CheckStdlv( "1000", cl_fix_resize("01111", (true, 3, 1), (true, 3, 0), Round_s, None_s),
                    "cl_fix_resize: Overflow due rounding, Signed, Wrap");
        CheckStdlv( "0111", cl_fix_resize("01111", (true, 3, 1), (true, 3, 0), Round_s, Sat_s),
                    "cl_fix_resize: Overflow due rounding, Signed, Sat");
        CheckStdlv( "000", cl_fix_resize("1111", (false, 3, 1), (false, 3, 0), Round_s, None_s),
                    "cl_fix_resize: Overflow due rounding, Unsigned, Wrap");
        CheckStdlv( "111", cl_fix_resize("1111", (false, 3, 1), (false, 3, 0), Round_s, Sat_s),
                    "cl_fix_resize: Overflow due rounding, Unsigned, Sat");
                    
        CheckStdlv( "1111", cl_fix_resize("11111", (true, 3, 1), (true, 3, 0), NonSymNeg_s, None_s),
                    "cl_fix_resize: NonSymNeg_s -0.5");
        CheckStdlv( "1110", cl_fix_resize("11101", (true, 3, 1), (true, 3, 0), NonSymNeg_s, None_s),
                    "cl_fix_resize: NonSymNeg_s -1.5");
        CheckStdlv( "0000", cl_fix_resize("00001", (true, 3, 1), (true, 3, 0), NonSymNeg_s, None_s),
                    "cl_fix_resize: NonSymNeg_s 0.5");
        CheckStdlv( "0001", cl_fix_resize("00011", (true, 3, 1), (true, 3, 0), NonSymNeg_s, None_s),
                    "cl_fix_resize: NonSymNeg_s 1.5");
        CheckStdlv( "0010", cl_fix_resize("000111", (true, 3, 2), (true, 3, 0), NonSymNeg_s, None_s),
                    "cl_fix_resize: NonSymNeg_s 1.75");
                    
        CheckStdlv( "1111", cl_fix_resize("11111", (true, 3, 1), (true, 3, 0), SymInf_s, None_s),
                    "cl_fix_resize: SymInf_s -0.5");
        CheckStdlv( "1110", cl_fix_resize("11101", (true, 3, 1), (true, 3, 0), SymInf_s, None_s),
                    "cl_fix_resize: SymInf_s -1.5");
        CheckStdlv( "0001", cl_fix_resize("00001", (true, 3, 1), (true, 3, 0), SymInf_s, None_s),
                    "cl_fix_resize: SymInf_s 0.5");
        CheckStdlv( "0010", cl_fix_resize("00011", (true, 3, 1), (true, 3, 0), SymInf_s, None_s),
                    "cl_fix_resize: SymInf_s 1.5");
        CheckStdlv( "0010", cl_fix_resize("000111", (true, 3, 2), (true, 3, 0), SymInf_s, None_s),
                    "cl_fix_resize: SymInf_s 1.75");
                    
        CheckStdlv( "0000", cl_fix_resize("11111", (true, 3, 1), (true, 3, 0), SymZero_s, None_s),
                    "cl_fix_resize: SymZero_s -0.5");
        CheckStdlv( "1111", cl_fix_resize("11101", (true, 3, 1), (true, 3, 0), SymZero_s, None_s),
                    "cl_fix_resize: SymZero_s -1.5");
        CheckStdlv( "0000", cl_fix_resize("00001", (true, 3, 1), (true, 3, 0), SymZero_s, None_s),
                    "cl_fix_resize: SymZero_s 0.5");
        CheckStdlv( "0001", cl_fix_resize("00011", (true, 3, 1), (true, 3, 0), SymZero_s, None_s),
                    "cl_fix_resize: SymZero_s 1.5");
        CheckStdlv( "0010", cl_fix_resize("000111", (true, 3, 2), (true, 3, 0), SymZero_s, None_s),
                    "cl_fix_resize: SymZero_s 1.75");
                    
        CheckStdlv( "0000", cl_fix_resize("11111", (true, 3, 1), (true, 3, 0), ConvEven_s, None_s),
                    "cl_fix_resize: ConvEven_s -0.5");
        CheckStdlv( "1110", cl_fix_resize("11101", (true, 3, 1), (true, 3, 0), ConvEven_s, None_s),
                    "cl_fix_resize: ConvEven_s -1.5");
        CheckStdlv( "0000", cl_fix_resize("00001", (true, 3, 1), (true, 3, 0), ConvEven_s, None_s),
                    "cl_fix_resize: ConvEven_s 0.5");
        CheckStdlv( "0010", cl_fix_resize("00011", (true, 3, 1), (true, 3, 0), ConvEven_s, None_s),
                    "cl_fix_resize: ConvEven_s 1.5");
        CheckStdlv( "0010", cl_fix_resize("000111", (true, 3, 2), (true, 3, 0), ConvEven_s, None_s),
                    "cl_fix_resize: ConvEven_s 1.75");
                    
        CheckStdlv( "1111", cl_fix_resize("11111", (true, 3, 1), (true, 3, 0), ConvOdd_s, None_s),
                    "cl_fix_resize: ConvOdd_s -0.5");
        CheckStdlv( "1111", cl_fix_resize("11101", (true, 3, 1), (true, 3, 0), ConvOdd_s, None_s),
                    "cl_fix_resize: ConvOdd_s -1.5");
        CheckStdlv( "0001", cl_fix_resize("00001", (true, 3, 1), (true, 3, 0), ConvOdd_s, None_s),
                    "cl_fix_resize: ConvOdd_s 0.5");
        CheckStdlv( "0001", cl_fix_resize("00011", (true, 3, 1), (true, 3, 0), ConvOdd_s, None_s),
                    "cl_fix_resize: ConvOdd_s 1.5");
        CheckStdlv( "0010", cl_fix_resize("000111", (true, 3, 2), (true, 3, 0), ConvOdd_s, None_s),
                    "cl_fix_resize: ConvOdd_s 1.75");
                    
        -- error cases
        CheckStdlv( "0000101000", cl_fix_resize(cl_fix_from_real(2.5, (false, 5, 4)), (false, 5, 4), (false, 6, 4)),
                    "cl_fix_resize: Overflow due rounding, Unsigned, Sat");
        CheckStdlv( "000010100", cl_fix_resize(cl_fix_from_real(1.25, (false, 5, 3)), (false, 5, 3), (false, 5, 4)),
                    "cl_fix_resize: Overflow due rounding, Unsigned, Sat");
                    
        -- *** cl_fix_add ***
        print("*** cl_fix_add ***");
        CheckStdlv( cl_fix_from_real(-2.5+1.25, (true, 5, 3)),
                    cl_fix_add( cl_fix_from_real(-2.5, (true, 5, 3)), (true, 5, 3),
                                cl_fix_from_real(1.25, (true, 5, 3)), (true, 5, 3),
                                (true, 5, 3)),
                    "cl_fix_add: Same Fmt Signed");
        CheckStdlv( cl_fix_from_real(2.5+1.25, (false, 5, 3)),
                    cl_fix_add( cl_fix_from_real(2.5, (false, 5, 3)), (false, 5, 3),
                                cl_fix_from_real(1.25, (false, 5, 3)), (false, 5, 3),
                                (false, 5, 3)),
                    "cl_fix_add: Same Fmt Usigned");
        CheckStdlv( cl_fix_from_real(-2.5+1.25, (true, 5, 3)),
                    cl_fix_add( cl_fix_from_real(-2.5, (true, 6, 3)), (true, 6, 3),
                                cl_fix_from_real(1.25, (true, 5, 3)), (true, 5, 3),
                                (true, 5, 3)),
                    "cl_fix_add: Different Int Bits Signed");
        CheckStdlv( cl_fix_from_real(2.5+1.25, (false, 5, 3)),
                    cl_fix_add( cl_fix_from_real(2.5, (false, 6, 3)), (false, 6, 3),
                                cl_fix_from_real(1.25, (false, 5, 3)), (false, 5, 3),
                                (false, 5, 3)),
                    "cl_fix_add: Different Int Bits Usigned");
        CheckStdlv( cl_fix_from_real(-2.5+1.25, (true, 5, 3)),
                    cl_fix_add( cl_fix_from_real(-2.5, (true, 5, 4)), (true, 5, 4),
                                cl_fix_from_real(1.25, (true, 5, 3)), (true, 5, 3),
                                (true, 5, 3)),
                    "cl_fix_add: Different Frac Bits Signed");
        CheckStdlv( cl_fix_from_real(2.5+1.25, (false, 5, 3)),
                    cl_fix_add( cl_fix_from_real(2.5, (false, 5, 4)), (false, 5, 4),
                                cl_fix_from_real(1.25, (false, 5, 3)), (false, 5, 3),
                                (false, 5, 3)),
                    "cl_fix_add: Different Frac Bits Usigned");
        CheckStdlv( cl_fix_from_real(0.75+4.0, (false, 5, 5)),
                    cl_fix_add( cl_fix_from_real(0.75, (false, 0, 4)), (false, 0, 4),
                                cl_fix_from_real(4.0, (false, 4, -1)), (false, 4, -1),
                                (false, 5, 5)),
                    "cl_fix_add: Different Ranges Unsigned");
        CheckStdlv( cl_fix_from_real(5.0, (false, 5, 0)),
                    cl_fix_add( cl_fix_from_real(0.75, (false, 0, 4)), (false, 0, 4),
                                cl_fix_from_real(4.0, (false, 4, -1)), (false, 4, -1),
                                (false, 5, 0), Round_s),
                    "cl_fix_add: Round");
        CheckStdlv( cl_fix_from_real(15.0, (false, 4, 0)),
                    cl_fix_add( cl_fix_from_real(0.75, (false, 0, 4)), (false, 0, 4),
                                cl_fix_from_real(15.0, (false, 4, 0)), (false, 4, 0),
                                (false, 4, 0), Round_s, Sat_s),
                    "cl_fix_add: Satturate");
                    
        -- *** cl_fix_sub ***
        print("*** cl_fix_sub ***");
        CheckStdlv( cl_fix_from_real(-2.5-1.25, (true, 5, 3)),
                    cl_fix_sub( cl_fix_from_real(-2.5, (true, 5, 3)), (true, 5, 3),
                                cl_fix_from_real(1.25, (true, 5, 3)), (true, 5, 3),
                                (true, 5, 3)),
                    "cl_fix_sub: Same Fmt Signed");
        CheckStdlv( cl_fix_from_real(2.5-1.25, (false, 5, 3)),
                    cl_fix_sub( cl_fix_from_real(2.5, (false, 5, 3)), (false, 5, 3),
                                cl_fix_from_real(1.25, (false, 5, 3)), (false, 5, 3),
                                (false, 5, 3)),
                    "cl_fix_sub: Same Fmt Usigned");
        CheckStdlv( cl_fix_from_real(-2.5-1.25, (true, 5, 3)),
                    cl_fix_sub( cl_fix_from_real(-2.5, (true, 6, 3)), (true, 6, 3),
                                cl_fix_from_real(1.25, (true, 5, 3)), (true, 5, 3),
                                (true, 5, 3)),
                    "cl_fix_sub: Different Int Bits Signed");
        CheckStdlv( cl_fix_from_real(2.5-1.25, (false, 5, 3)),
                    cl_fix_sub( cl_fix_from_real(2.5, (false, 6, 3)), (false, 6, 3),
                                cl_fix_from_real(1.25, (false, 5, 3)), (false, 5, 3),
                                (false, 5, 3)),
                    "cl_fix_sub: Different Int Bits Usigned");
        CheckStdlv( cl_fix_from_real(-2.5-1.25, (true, 5, 3)),
                    cl_fix_sub( cl_fix_from_real(-2.5, (true, 5, 4)), (true, 5, 4),
                                cl_fix_from_real(1.25, (true, 5, 3)), (true, 5, 3),
                                (true, 5, 3)),
                    "cl_fix_sub: Different Frac Bits Signed");
        CheckStdlv( cl_fix_from_real(2.5-1.25, (false, 5, 3)),
                    cl_fix_sub( cl_fix_from_real(2.5, (false, 5, 4)), (false, 5, 4),
                                cl_fix_from_real(1.25, (false, 5, 3)), (false, 5, 3),
                                (false, 5, 3)),
                    "cl_fix_sub: Different Frac Bits Usigned");
        CheckStdlv( cl_fix_from_real(4.0-0.75, (false, 5, 5)),
                    cl_fix_sub( cl_fix_from_real(4.0, (false, 4, -1)), (false, 4, -1),
                                cl_fix_from_real(0.75, (false, 0, 4)), (false, 0, 4),
                                (false, 5, 5)),
                    "cl_fix_sub: Different Ranges Unsigned");
        CheckStdlv( cl_fix_from_real(4.0, (false, 5, 0)),
                    cl_fix_sub( cl_fix_from_real(4.0, (false, 4, -1)), (false, 4, -1),
                                cl_fix_from_real(0.25, (false, 0, 4)), (false, 0, 4),
                                (false, 5, 0), Round_s),
                    "cl_fix_sub: Round");
        CheckStdlv( cl_fix_from_real(0.0, (false, 4, 0)),
                    cl_fix_sub( cl_fix_from_real(0.75, (false, 0, 4)), (false, 0, 4),
                                cl_fix_from_real(5.0, (false, 4, 0)), (false, 4, 0),
                                (false, 4, 0), Round_s, Sat_s),
                    "cl_fix_sub: Satturate");
        CheckStdlv( cl_fix_from_real(-16.0, (true, 4, 0)),
                    cl_fix_sub( cl_fix_from_real(0.0, (true, 4, 0)), (true, 4, 0),
                                cl_fix_from_real(-16.0, (true, 4, 0)), (true, 4, 0),
                                (true, 4, 0), Round_s, None_s),
                    "cl_fix_sub: Invert most negative signed, noSat");
        CheckStdlv( cl_fix_from_real(15.0, (true, 4, 0)),
                    cl_fix_sub( cl_fix_from_real(0.0, (true, 4, 0)), (true, 4, 0),
                                cl_fix_from_real(-16.0, (true, 4, 0)), (true, 4, 0),
                                (true, 4, 0), Round_s, Sat_s),
                    "cl_fix_sub: Invert most negative signed, Sat");
        CheckStdlv( cl_fix_from_real(1.0, (false, 4, 0)),
                    cl_fix_sub( cl_fix_from_real(0.0, (false, 4, 0)), (false, 4, 0),
                                cl_fix_from_real(15.0, (false, 4, 0)), (false, 4, 0),
                                (false, 4, 0), Round_s, None_s),
                    "cl_fix_sub: Invert most negative unsigned, noSat");
        CheckStdlv( cl_fix_from_real(0.0, (false, 4, 0)),
                    cl_fix_sub( cl_fix_from_real(0.0, (false, 4, 0)), (false, 4, 0),
                                cl_fix_from_real(15.0, (false, 4, 0)), (false, 4, 0),
                                (false, 4, 0), Round_s, Sat_s),
                    "cl_fix_sub: Invert unsigned, Sat");
                    
        -- *** cl_fix_mult ***
        print("*** cl_fix_mult ***");
        CheckStdlv( cl_fix_from_real(2.5*1.25, (false, 5, 5)),
                    cl_fix_mult(    cl_fix_from_real(2.5, (false, 5, 1)), (false, 5, 1),
                                cl_fix_from_real(1.25, (false, 5, 2)), (false, 5, 2),
                                (false, 5, 5)),
                    "cl_fix_mult: A unsigned positive, B unsigned positive");
        CheckStdlv( cl_fix_from_real(2.5*1.25, (true, 3, 3)),
                    cl_fix_mult(    cl_fix_from_real(2.5, (true, 2, 1)), (true, 2, 1),
                                cl_fix_from_real(1.25, (true, 1, 2)), (true, 1, 2),
                                (true, 3, 3)),
                    "cl_fix_mult: A signed positive, B signed positive");
        CheckStdlv( cl_fix_from_real(2.5*(-1.25), (true, 3, 3)),
                    cl_fix_mult(    cl_fix_from_real(2.5, (true, 2, 1)), (true, 2, 1),
                                cl_fix_from_real(-1.25, (true, 1, 2)), (true, 1, 2),
                                (true, 3, 3)),
                    "cl_fix_mult: A signed positive, B signed negative");
        CheckStdlv( cl_fix_from_real((-2.5)*1.25, (true, 3, 3)),
                    cl_fix_mult(    cl_fix_from_real(-2.5, (true, 2, 1)), (true, 2, 1),
                                cl_fix_from_real(1.25, (true, 1, 2)), (true, 1, 2),
                                (true, 3, 3)),
                    "cl_fix_mult: A signed negative, B signed positive");
        CheckStdlv( cl_fix_from_real((-2.5)*(-1.25), (true, 3, 3)),
                    cl_fix_mult(    cl_fix_from_real(-2.5, (true, 2, 1)), (true, 2, 1),
                                cl_fix_from_real(-1.25, (true, 1, 2)), (true, 1, 2),
                                (true, 3, 3)),
                    "cl_fix_mult: A signed negative, B signed negative");
        CheckStdlv( cl_fix_from_real(2.5*1.25, (true, 3, 3)),
                    cl_fix_mult(    cl_fix_from_real(2.5, (false, 2, 1)), (false, 2, 1),
                                cl_fix_from_real(1.25, (true, 1, 2)), (true, 1, 2),
                                (true, 3, 3)),
                    "cl_fix_mult: A unsigned positive, B signed positive");
        CheckStdlv( cl_fix_from_real(2.5*(-1.25), (true, 3, 3)),
                    cl_fix_mult(    cl_fix_from_real(2.5, (false, 2, 1)), (false, 2, 1),
                                cl_fix_from_real(-1.25, (true, 1, 2)), (true, 1, 2),
                                (true, 3, 3)),
                    "cl_fix_mult: A unsigned positive, B signed negative");
        CheckStdlv( cl_fix_from_real(2.5*1.25, (false, 3, 3)),
                    cl_fix_mult(    cl_fix_from_real(2.5, (false, 2, 1)), (false, 2, 1),
                                cl_fix_from_real(1.25, (true, 1, 2)), (true, 1, 2),
                                (false, 3, 3)),
                    "cl_fix_mult: A unsigned positive, B signed positive, result unsigned");
        CheckStdlv( cl_fix_from_real(1.875, (false, 1, 3)),
                    cl_fix_mult(    cl_fix_from_real(2.5, (false, 2, 1)), (false, 2, 1),
                                cl_fix_from_real(1.25, (true, 1, 2)), (true, 1, 2),
                                (false, 1, 3), Trunc_s, Sat_s),
                    "cl_fix_mult: A unsigned positive, B signed positive, saturate");
                    
        -- *** cl_fix_abs ***
        print("*** cl_fix_abs ***");
        CheckStdlv( cl_fix_from_real(2.5, (false, 5, 5)),
                    cl_fix_abs( cl_fix_from_real(2.5, (false, 5, 1)), (false, 5, 1),
                                (false, 5, 5)),
                    "cl_fix_abs: positive stay positive");
        CheckStdlv( cl_fix_from_real(4.0, (true, 3, 3)),
                    cl_fix_abs( cl_fix_from_real(-4.0, (true, 2, 2)), (true, 2, 2),
                                (true, 3, 3)),
                    "cl_fix_abs: negative becomes positive");
        CheckStdlv( cl_fix_from_real(3.75, (true, 2, 2)),
                    cl_fix_abs( cl_fix_from_real(-4.0, (true, 2, 2)), (true, 2, 2),
                                (true, 2, 2), Trunc_s, Sat_s),
                    "cl_fix_abs: most negative value sat");
                    
        -- *** cl_fix_neg ***
        print("*** cl_fix_neg ***");
        CheckStdlv( cl_fix_from_real(-2.5, (true, 5, 5)),
                    cl_fix_neg( cl_fix_from_real(2.5, (true, 5, 1)), (true, 5, 1), '1',
                                (true, 5, 5)),
                    "cl_fix_neg: positive to negative (signed -> signed)");
        CheckStdlv( cl_fix_from_real(-2.5, (true, 5, 5)),
                    cl_fix_neg( cl_fix_from_real(2.5, (false, 5, 1)), (false, 5, 1), '1',
                                (true, 5, 5)),
                    "cl_fix_neg: positive to negative (unsigned -> signed)");
        CheckStdlv( cl_fix_from_real(2.5, (true, 5, 5)),
                    cl_fix_neg( cl_fix_from_real(-2.5, (true, 5, 1)), (true, 5, 1), '1',
                                (true, 5, 5)),
                    "cl_fix_neg: negative to positive (signed -> signed)");
        CheckStdlv( cl_fix_from_real(2.5, (false, 5, 5)),
                    cl_fix_neg( cl_fix_from_real(-2.5, (true, 5, 1)), (true, 5, 1), '1',
                                (false, 5, 5)),
                    "cl_fix_neg: negative to positive (signed -> unsigned)");
        CheckStdlv( cl_fix_from_real(3.75, (true, 2, 2)),
                    cl_fix_neg( cl_fix_from_real(-4.0, (true, 2, 4)), (true, 2, 4), '1',
                                (true, 2, 2), Trunc_s, Sat_s),
                    "cl_fix_neg: saturation (signed -> signed)");
        CheckStdlv( cl_fix_from_real(-4.0, (true, 2, 2)),
                    cl_fix_neg( cl_fix_from_real(-4.0, (true, 2, 4)), (true, 2, 4), '1',
                                (true, 2, 2), Trunc_s, None_s),
                    "cl_fix_neg: wrap (signed -> signed)");
        CheckStdlv( cl_fix_from_real(0.0, (false, 5, 5)),
                    cl_fix_neg( cl_fix_from_real(2.5, (true, 5, 1)), (true, 5, 1), '1',
                                (false, 5, 5), Trunc_s, Sat_s),
                    "cl_fix_neg: positive to negative saturate (signed -> unsigned)");
                    
        -- *** cl_fix_shift left***
        print("*** cl_fix_shift left ***");
        CheckStdlv( cl_fix_from_real(2.5, (false, 3, 2)),
                    cl_fix_shift(   cl_fix_from_real(1.25, (false, 3, 2)),  (false, 3, 2),
                                    1,
                                    (false, 3, 2)),
                                    "Shift same format unsigned");
        CheckStdlv( cl_fix_from_real(2.5, (true, 3, 2)),
                    cl_fix_shift(   cl_fix_from_real(1.25, (true, 3, 2)),   (true, 3, 2),
                                    1,
                                    (true, 3, 2)),
                                    "Shift same format signed");
        CheckStdlv( cl_fix_from_real(2.5, (false, 3, 2)),
                    cl_fix_shift(   cl_fix_from_real(1.25, (true, 1, 2)),   (true, 1, 2),
                                    1,
                                    (false, 3, 2)),
                                    "Shift format change");
        CheckStdlv( cl_fix_from_real(3.75, (true, 2, 2)),
                    cl_fix_shift(   cl_fix_from_real(2.0, (true, 2, 2)),    (true, 2, 2),
                                    1,
                                    (true, 2, 2), Trunc_s, Sat_s),
                                    "saturation signed");
        CheckStdlv( cl_fix_from_real(3.75, (true, 2, 2)),
                    cl_fix_shift(   cl_fix_from_real(2.0, (false, 3, 2)),   (false, 3, 2),
                                    1,
                                    (true, 2, 2), Trunc_s, Sat_s),
                                    "saturation unsigned to signed");
        CheckStdlv( cl_fix_from_real(0.0, (false, 2, 2)),
                    cl_fix_shift(   cl_fix_from_real(-0.5, (true, 3, 2)),   (true, 3, 2),
                                    1,
                                    (false, 2, 2), Trunc_s, Sat_s),
                                    "saturation signed to unsigned");
        CheckStdlv( cl_fix_from_real(-4.0, (true, 2, 2)),
                    cl_fix_shift(   cl_fix_from_real(2.0, (true, 2, 2)),    (true, 2, 2),
                                    1,
                                    (true, 2, 2), Trunc_s, None_s),
                                    "wrap signed");
        CheckStdlv( cl_fix_from_real(-4.0, (true, 2, 2)),
                    cl_fix_shift(   cl_fix_from_real(2.0, (false, 3, 2)),   (false, 3, 2),
                                    1,
                                    (true, 2, 2), Trunc_s, None_s),
                                    "wrap unsigned to signed");
        CheckStdlv( cl_fix_from_real(3.0, (false, 2, 2)),
                    cl_fix_shift(   cl_fix_from_real(-0.5, (true, 3, 2)), (true, 3, 2),
                                    1,
                                    (false, 2, 2), Trunc_s, None_s),
                                    "wrap signed to unsigned");
        CheckStdlv( cl_fix_from_real(0.5, (true, 5, 5)),
                    cl_fix_shift(   cl_fix_from_real(0.5, (true, 5, 5)), (true, 5, 5),
                                    0,
                                    (true, 5, 5), Trunc_s, None_s),
                                    "shift 0");
        CheckStdlv( cl_fix_from_real(-4.0, (true, 5, 5)),
                    cl_fix_shift(   cl_fix_from_real(-0.5, (true, 5, 5)), (true, 5, 5),
                                    3,
                                    (true, 5, 5), Trunc_s, None_s),
                                    "shift 3");
                                    
        -- *** cl_fix_shift right ***
        print("*** cl_fix_shift right  ***");
        CheckStdlv( cl_fix_from_real(1.25, (false, 3, 2)),
                    cl_fix_shift(   cl_fix_from_real(2.5, (false, 3, 2)),   (false, 3, 2),
                                    -1,
                                    (false, 3, 2)),
                                    "Shift same format unsigned");
        CheckStdlv( cl_fix_from_real(1.25, (true, 3, 2)),
                    cl_fix_shift(   cl_fix_from_real(2.5, (true, 3, 2)),    (true, 3, 2),
                                    -1,
                                    (true, 3, 2)),
                                    "Shift same format signed");
        CheckStdlv( cl_fix_from_real(1.25, (true, 1, 2)),
                    cl_fix_shift(   cl_fix_from_real(2.5, (false, 3, 2)),   (false, 3, 2),
                                    -1,
                                    (true, 1, 2)),
                                    "Shift format change");
        CheckStdlv( cl_fix_from_real(0.0, (false, 2, 2)),
                    cl_fix_shift(   cl_fix_from_real(-0.5, (true, 3, 2)),   (true, 3, 2),
                                    -1,
                                    (false, 2, 2), Trunc_s, Sat_s),
                                    "saturation signed to unsigned");
        CheckStdlv( cl_fix_from_real(0.5, (true, 5, 5)),
                    cl_fix_shift(   cl_fix_from_real(0.5, (true, 5, 5)), (true, 5, 5),
                                    0,
                                    (true, 5, 5), Trunc_s, None_s),
                                    "shift 0");
        CheckStdlv( cl_fix_from_real(-0.5, (true, 5, 5)),
                    cl_fix_shift(   cl_fix_from_real(-4.0, (true, 5, 5)), (true, 5, 5),
                                    -3,
                                    (true, 5, 5), Trunc_s, None_s),
                                    "shift 3");
                                    
        -- *** cl_fix_max_value ***
        print("*** cl_fix_max_value ***");
        CheckStdlv( "1111", cl_fix_max_value((false,2,2)), "unsigned");
        CheckStdlv( "0111", cl_fix_max_value((true,1,2)), "signed");
        
        -- *** cl_fix_min_value ***
        print("*** cl_fix_min_value ***");
        CheckStdlv( "0000", cl_fix_min_value((false,2,2)), "unsigned");
        CheckStdlv( "1000", cl_fix_min_value((true,1,2)), "signed");
        
        -- *** cl_fix_max_real ***
        print("*** cl_fix_max_real ***");
        CheckReal(  3.75, cl_fix_max_real((false,2,2)), "unsigned");
        CheckReal(  1.75, cl_fix_max_real((true,1,2)), "signed");
        
        -- *** cl_fix_min_real ***
        print("*** cl_fix_min_real ***");
        CheckReal(  0.0, cl_fix_min_real((false,2,2)), "unsigned");
        CheckReal(  -2.0, cl_fix_min_real((true,1,2)), "signed");
        
        -- *** cl_fix_in_range ***
        print("*** cl_fix_in_range ***");
        CheckBoolean(   true,
                        cl_fix_in_range(cl_fix_from_real(1.25, (true, 4, 2)), (true, 4, 2),
                                        (true, 2, 4), Trunc_s),
                        "In Range Normal");
        CheckBoolean(   false,
                        cl_fix_in_range(cl_fix_from_real(6.25, (true, 4, 2)), (true, 4, 2),
                                        (true, 2, 4), Trunc_s),
                        "Out Range Normal");
        CheckBoolean(   false,
                        cl_fix_in_range(cl_fix_from_real(-1.25, (true, 4, 2)), (true, 4, 2),
                                        (false, 5, 2), Trunc_s),
                        "signed -> unsigned OOR");
        CheckBoolean(   false,
                        cl_fix_in_range(cl_fix_from_real(15.0, (false, 4, 2)), (false, 4, 2),
                                        (true, 3, 2), Trunc_s),
                        "unsigned -> signed OOR");
        CheckBoolean(   true,
                        cl_fix_in_range(cl_fix_from_real(15.0, (false, 4, 2)), (false, 4, 2),
                                        (true, 4, 2), Trunc_s),
                        "unsigned -> signed OK");
        CheckBoolean(   false,
                        cl_fix_in_range(cl_fix_from_real(15.5, (false, 4, 2)), (false, 4, 2),
                                        (true, 4, 0), Round_s),
                        "rounding OOR");
        CheckBoolean(   true,
                        cl_fix_in_range(cl_fix_from_real(15.5, (false, 4, 2)), (false, 4, 2),
                                        (true, 4, 1), Round_s),
                        "rounding OK 1");
        CheckBoolean(   true,
                        cl_fix_in_range(cl_fix_from_real(15.5, (false, 4, 2)), (false, 4, 2),
                                        (false, 5, 0), Round_s),
                        "rounding OK 2");
                        
        -- *** cl_fix_compare ***
        print("*** cl_fix_compare ***");
        CheckBoolean(   true,
                        cl_fix_compare( "a<b",
                                        cl_fix_from_real(1.25, (false, 4, 2)), (false, 4, 2),
                                        cl_fix_from_real(1.5, (false, 2, 1)), (false, 2, 1)),
                        "a<b unsigned unsigned true");
        CheckBoolean(   false,
                        cl_fix_compare( "a<b",
                                        cl_fix_from_real(1.5, (false, 4, 2)), (false, 4, 2),
                                        cl_fix_from_real(1.5, (false, 2, 1)), (false, 2, 1)),
                        "a<b unsigned unsigned false");
        CheckBoolean(   true,
                        cl_fix_compare( "a<b",
                                        cl_fix_from_real(1.25, (true, 4, 2)), (true, 4, 2),
                                        cl_fix_from_real(1.5, (false, 2, 1)), (false, 2, 1)),
                        "a<b signed unsigned true");
        CheckBoolean(   false,
                        cl_fix_compare( "a<b",
                                        cl_fix_from_real(2.5, (false, 4, 2)), (false, 4, 2),
                                        cl_fix_from_real(1.5, (true, 2, 1)), (true, 2, 1)),
                        "a<b unsigned signed false");
        CheckBoolean(   true,
                        cl_fix_compare( "a<b",
                                        cl_fix_from_real(-1.25, (true, 4, 2)), (true, 4, 2),
                                        cl_fix_from_real(-1.0, (true, 2, 1)), (true, 2, 1)),
                        "a<b signed signed true");
        CheckBoolean(   false,
                        cl_fix_compare( "a<b",
                                        cl_fix_from_real(-0.5, (true, 4, 2)), (true, 4, 2),
                                        cl_fix_from_real(-1.5, (true, 2, 1)), (true, 2, 1)),
                        "a<b signed signed false");
                        
        CheckBoolean(   true,
                        cl_fix_compare( "a=b",
                                        cl_fix_from_real(1.5, (true, 4, 2)), (true, 4, 2),
                                        cl_fix_from_real(1.5, (false, 2, 1)), (false, 2, 1)),
                        "a=b signed unsigned true");
        CheckBoolean(   false,
                        cl_fix_compare( "a=b",
                                        cl_fix_from_real(2.5, (false, 4, 2)), (false, 4, 2),
                                        cl_fix_from_real(-1.5, (true, 2, 1)), (true, 2, 1)),
                        "a=b unsigned signed false");
                        
        CheckBoolean(   true,
                        cl_fix_compare( "a>b",
                                        cl_fix_from_real(2.5, (true, 4, 2)), (true, 4, 2),
                                        cl_fix_from_real(1.5, (false, 2, 1)), (false, 2, 1)),
                        "a>b signed unsigned true");
        CheckBoolean(   false,
                        cl_fix_compare( "a>b",
                                        cl_fix_from_real(1.5, (false, 4, 2)), (false, 4, 2),
                                        cl_fix_from_real(1.5, (true, 2, 1)), (true, 2, 1)),
                        "a>b unsigned signed false");
                        
        CheckBoolean(   true,
                        cl_fix_compare( "a>=b",
                                        cl_fix_from_real(2.5, (true, 4, 2)), (true, 4, 2),
                                        cl_fix_from_real(1.5, (false, 2, 1)), (false, 2, 1)),
                        "a>=b signed unsigned true 1");
        CheckBoolean(   true,
                        cl_fix_compare( "a>=b",
                                        cl_fix_from_real(1.5, (true, 4, 2)), (true, 4, 2),
                                        cl_fix_from_real(1.5, (false, 2, 1)), (false, 2, 1)),
                        "a>=b signed unsigned true 2");
        CheckBoolean(   false,
                        cl_fix_compare( "a>=b",
                                        cl_fix_from_real(1.25, (false, 4, 2)), (false, 4, 2),
                                        cl_fix_from_real(1.5, (true, 2, 1)), (true, 2, 1)),
                        "a>=b unsigned signed false 1");
                        
        CheckBoolean(   true,
                        cl_fix_compare( "a<=b",
                                        cl_fix_from_real(-2.5, (true, 4, 2)), (true, 4, 2),
                                        cl_fix_from_real(1.5, (false, 2, 1)), (false, 2, 1)),
                        "a<=b signed unsigned true 1");
        CheckBoolean(   true,
                        cl_fix_compare( "a<=b",
                                        cl_fix_from_real(1.5, (true, 4, 2)), (true, 4, 2),
                                        cl_fix_from_real(1.5, (false, 2, 1)), (false, 2, 1)),
                        "a<=b signed unsigned true 2");
        CheckBoolean(   false,
                        cl_fix_compare( "a<=b",
                                        cl_fix_from_real(0.25, (false, 4, 2)), (false, 4, 2),
                                        cl_fix_from_real(-1.5, (true, 2, 1)), (true, 2, 1)),
                        "a<=b unsigned signed false 1");
                        
        CheckBoolean(   false,
                        cl_fix_compare( "a!=b",
                                        cl_fix_from_real(1.5, (true, 4, 2)), (true, 4, 2),
                                        cl_fix_from_real(1.5, (false, 2, 1)), (false, 2, 1)),
                        "a!=b signed unsigned false");
        CheckBoolean(   true,
                        cl_fix_compare( "a!=b",
                                        cl_fix_from_real(2.5, (false, 4, 2)), (false, 4, 2),
                                        cl_fix_from_real(-1.5, (true, 2, 1)), (true, 2, 1)),
                        "a!=b unsigned signed true");
                        
        -- *** cl_fix_sign ***
        print("*** cl_fix_sign ***");
        CheckStdl(  '0', cl_fix_sign(cl_fix_from_real(3.25, (false, 2, 2)), (false,2,2)), "Unsigned");
        CheckStdl(  '1', cl_fix_sign(cl_fix_from_real(-1.25, (true, 2, 2)), (true,2,2)), "SignedOne");
        CheckStdl(  '0', cl_fix_sign(cl_fix_from_real(3.25, (true, 2, 2)), (true,2,2)), "SignedZero");
        
        -- *** cl_fix_int ***
        print("*** cl_fix_int ***");
        CheckStdlv( "11", cl_fix_int(cl_fix_from_real(3.25, (false, 2, 2)), (false,2,2)), "Unsigned");
        CheckStdlv( "11", cl_fix_int(cl_fix_from_real(3.25, (true, 2, 2)), (true,2,2)), "SignedOne");
        CheckStdlv( "10", cl_fix_int(cl_fix_from_real(-1.25, (true, 2, 2)), (true,2,2)), "SignedZero");
        
        -- *** cl_fix_frac ***
        print("*** cl_fix_frac ***");
        CheckStdlv( "010", cl_fix_frac(cl_fix_from_real(3.25, (false, 2, 3)), (false,2,3)), "Test");
        
        -- *** cl_fix_combine ***
        print("*** cl_fix_combine ***");
        CheckStdlv( cl_fix_from_real(-3.25, (True,2,2)),
                    cl_fix_combine('1', "00", "11", (True,2,2)), "Test");
                    
        -- *** cl_fix_get_msb ***
        print("*** cl_fix_get_msb ***");
        CheckStdl(  '1', cl_fix_get_msb(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), 2), "One");
        CheckStdl(  '0', cl_fix_get_msb(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), 1), "Zero");
        
        -- *** cl_fix_get_lsb ***
        print("*** cl_fix_get_lsb ***");
        CheckStdl(  '1', cl_fix_get_lsb(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), 1), "One");
        CheckStdl(  '0', cl_fix_get_lsb(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), 2), "Zero");
        
        -- *** cl_fix_set_msb ***
        print("*** cl_fix_set_msb ***");
        CheckStdlv( cl_fix_from_real(2.25, (true,3,3)),
                    cl_fix_set_msb(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), 2, '1'), "SetOne");
        CheckStdlv( cl_fix_from_real(6.25, (true,3,3)),
                    cl_fix_set_msb(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), 1, '1'), "SetZero");
        CheckStdlv( cl_fix_from_real(0.25, (true,3,3)),
                    cl_fix_set_msb(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), 2, '0'), "ClearOne");
        CheckStdlv( cl_fix_from_real(2.25, (true,3,3)),
                    cl_fix_set_msb(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), 1, '0'), "ClearZero");
                    
        -- *** cl_fix_set_lsb ***
        print("*** cl_fix_set_lsb ***");
        CheckStdlv( cl_fix_from_real(2.25, (true,3,3)),
                    cl_fix_set_lsb(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), 1, '1'), "SetOne");
        CheckStdlv( cl_fix_from_real(2.75, (true,3,3)),
                    cl_fix_set_lsb(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), 2, '1'), "SetZero");
        CheckStdlv( cl_fix_from_real(2.0, (true,3,3)),
                    cl_fix_set_lsb(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), 1, '0'), "ClearOne");
        CheckStdlv( cl_fix_from_real(2.25, (true,3,3)),
                    cl_fix_set_lsb(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), 2, '0'), "ClearZero");
                    
        -- *** cl_fix_sabs ***
        print("*** cl_fix_sabs ***");
        CheckStdlv( cl_fix_from_real(2.25, (false,2,2)),
                    cl_fix_sabs(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), (false,2,2)), "Positive");
        CheckStdlv( cl_fix_from_real(2.0, (false,2,2)),
                    cl_fix_sabs(cl_fix_from_real(-2.25, (true, 3, 3)), (true,3,3), (false,2,2)), "Negative");
                    
        -- *** cl_fix_sneg ***
        print("*** cl_fix_sneg ***");
        CheckStdlv( cl_fix_from_real(-2.5, (true,3,2)),
                    cl_fix_sneg(cl_fix_from_real(2.25, (true, 3, 3)), (true,3,3), '1', (true,3,2)), "Pos");
        CheckStdlv( cl_fix_from_real(2.0, (true,3,2)),
                    cl_fix_sneg(cl_fix_from_real(-2.25, (true, 3, 3)), (true,3,3), '1', (true,3,2)), "Neg");
                    
        -- *** cl_fix_addsub ***
        print("*** cl_fix_addsub ***");
        CheckStdlv( cl_fix_from_real(1.75, (true,3,3)),
                    cl_fix_addsub(  cl_fix_from_real(1.0, (true,3,3)), (true,3,3),
                                    cl_fix_from_real(0.75, (true,3,3)), (true,3,3), '1', (true,3,3)), "Add");
        CheckStdlv( cl_fix_from_real(1.0, (true,3,3)),
                    cl_fix_addsub(  cl_fix_from_real(1.25, (true,3,3)), (true,3,3),
                                    cl_fix_from_real(0.25, (true,3,3)), (true,3,3), '0', (true,3,3)), "Sub");
                                    
        -- *** cl_fix_saddsub ***
        print("*** cl_fix_saddsub ***");
        CheckStdlv( cl_fix_from_real(1.75, (true,3,2)),
                    cl_fix_saddsub( cl_fix_from_real(1.0, (true,3,2)), (true,3,2),
                                    cl_fix_from_real(0.75, (true,3,2)), (true,3,2), '1', (true,3,2)), "Add");
        CheckStdlv( cl_fix_from_real(0.75, (true,3,2)),
                    cl_fix_saddsub( cl_fix_from_real(1.25, (true,3,2)), (true,3,2),
                                    cl_fix_from_real(0.25, (true,3,2)), (true,3,2), '0', (true,3,2)), "Sub");
        wait;
    end process;
    
end sim;
