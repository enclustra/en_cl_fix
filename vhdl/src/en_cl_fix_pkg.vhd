---------------------------------------------------------------------------------------------------
-- Copyright (c) 2022 Enclustra GmbH, Switzerland (info@enclustra.com)
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Libraries
---------------------------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

library std;
    use std.textio.all;

---------------------------------------------------------------------------------------------------
-- Package Header
---------------------------------------------------------------------------------------------------

package en_cl_fix_pkg is

    -----------------------------------------------------------------------------------------------
    -- Types
    -----------------------------------------------------------------------------------------------
    
    type FixFormat_t is record
        Signed      : boolean;
        IntBits     : integer;
        FracBits    : integer;
    end record;
    
    type FixFormatArray_t is array(natural range <>) of FixFormat_t;
    
    type FixRound_t is
    (
        Trunc_s,        -- Discard LSBs.
        NonSymPos_s,    -- Non-symmetric rounding towards +infinity.
        NonSymNeg_s,    -- Non-symmetric rounding towards -infinity.
        SymInf_s,       -- Symmetric rounding towards +/- infinity.
        SymZero_s,      -- Symmetric rounding towards zero.
        ConvEven_s,     -- Convergent rounding to even number.
        ConvOdd_s       -- Convergent rounding to odd number.
    );
    
    type FixSaturate_t is
    (
        None_s,         -- No saturation, no warning.
        Warn_s,         -- No saturation, only warning.
        Sat_s,          -- Only saturation, no warning.
        SatWarn_s       -- Saturation and warning.
    );
    
    -----------------------------------------------------------------------------------------------
    -- Format Functions
    -----------------------------------------------------------------------------------------------
    
    function cl_fix_format(signed : boolean; intBits : integer; fracBits : integer) return FixFormat_t;
    
    function cl_fix_add_fmt(a_fmt : FixFormat_t; b_fmt : FixFormat_t) return FixFormat_t;
    
    function cl_fix_sub_fmt(a_fmt : FixFormat_t; b_fmt : FixFormat_t) return FixFormat_t;
    
    function cl_fix_mult_fmt(a_fmt : FixFormat_t; b_fmt : FixFormat_t) return FixFormat_t;
    
    function cl_fix_neg_fmt(a_fmt : FixFormat_t) return FixFormat_t;
    
    function cl_fix_shift_fmt(a_fmt : FixFormat_t; min_shift : integer; max_shift : integer) return FixFormat_t;
    
    function cl_fix_shift_fmt(a_fmt : FixFormat_t; shift : integer) return FixFormat_t;
    
    function cl_fix_width(fmt : FixFormat_t) return positive;
    
    function cl_fix_string_from_format(fmt : FixFormat_t) return string;
    
    function cl_fix_format_from_string(Str : string) return FixFormat_t;
    
    function cl_fix_round_from_string(Str : string) return FixRound_t;
    
    function cl_fix_saturate_from_string(Str : string) return FixSaturate_t;
    
    function cl_fix_zero_value(fmt : FixFormat_t) return std_logic_vector;
    
    function cl_fix_max_value(fmt : FixFormat_t) return std_logic_vector;
    
    function cl_fix_min_value(fmt : FixFormat_t) return std_logic_vector;
    
    function cl_fix_max_real(fmt : FixFormat_t) return real;
    
    function cl_fix_min_real(fmt : FixFormat_t) return real;
    
    function cl_fix_sign(a : std_logic_vector; a_fmt : FixFormat_t) return std_logic;
    
    function cl_fix_int(a : std_logic_vector; a_fmt : FixFormat_t) return std_logic_vector;
    
    function cl_fix_frac(a : std_logic_vector; a_fmt : FixFormat_t) return std_logic_vector;
    
    function cl_fix_combine(sign : std_logic; int : std_logic_vector; frac : std_logic_vector; result_fmt : FixFormat_t) return std_logic_vector;

    -----------------------------------------------------------------------------------------------
    -- Bit Manipulation
    -----------------------------------------------------------------------------------------------
    
    function cl_fix_get_msb(a : std_logic_vector; a_fmt : FixFormat_t; index : natural) return std_logic;
    
    function cl_fix_get_lsb(a : std_logic_vector; a_fmt : FixFormat_t; index : natural) return std_logic;
    
    function cl_fix_set_msb(a : std_logic_vector; a_fmt : FixFormat_t; index : natural; value : std_logic) return std_logic_vector;
    
    function cl_fix_set_lsb(a : std_logic_vector; a_fmt : FixFormat_t; index : natural; value : std_logic) return std_logic_vector;

    -----------------------------------------------------------------------------------------------
    -- Conversion To/From Other Formats
    -----------------------------------------------------------------------------------------------
    
    function cl_fix_from_int(a : integer; result_fmt : FixFormat_t; saturate : FixSaturate_t := SatWarn_s) return std_logic_vector;
    
    function cl_fix_to_int(a : std_logic_vector; a_fmt : FixFormat_t) return integer;
    
    function cl_fix_from_real(a : real; result_fmt : FixFormat_t; saturate : FixSaturate_t := SatWarn_s) return std_logic_vector;
    
    function cl_fix_to_real(a : std_logic_vector; a_fmt : FixFormat_t) return real;
    
    function cl_fix_from_bin(a : string; result_fmt : FixFormat_t) return std_logic_vector;
    
    function cl_fix_to_bin(a : std_logic_vector; a_fmt : FixFormat_t) return string;
    
    function cl_fix_from_hex(a : string; result_fmt : FixFormat_t) return std_logic_vector;
    
    function cl_fix_to_hex(a : std_logic_vector; a_fmt : FixFormat_t) return string;
    
    function cl_fix_get_bits_as_int(a : std_logic_vector; aFmt : FixFormat_t) return integer;
    
    function cl_fix_from_bits_as_int(a : integer; aFmt : FixFormat_t) return std_logic_vector;

    -----------------------------------------------------------------------------------------------
    -- File Operations
    -----------------------------------------------------------------------------------------------
    
    impure function cl_fix_read_int(   file a      : text;
                                        result_fmt  : FixFormat_t;
                                        saturate    : FixSaturate_t := SatWarn_s)
                                        return std_logic_vector;
    
    impure function cl_fix_read_real(  file a      : text;
                                        result_fmt  : FixFormat_t;
                                        saturate    : FixSaturate_t := SatWarn_s)
                                        return std_logic_vector;
    
    impure function cl_fix_read_bin(   file a      : text;
                                        result_fmt  : FixFormat_t)
                                        return std_logic_vector;
    
    impure function cl_fix_read_hex(   file a      : text;
                                        result_fmt  : FixFormat_t)
                                        return std_logic_vector;
    
    procedure cl_fix_write_int(    a           : std_logic_vector;
                                    a_fmt       : FixFormat_t;
                                    file f      : text;
                                    f_fmt       : FixFormat_t;
                                    round       : FixRound_t    := Trunc_s;
                                    saturate    : FixSaturate_t := Warn_s);
    
    procedure cl_fix_write_real(   a           : std_logic_vector;
                                    a_fmt       : FixFormat_t;
                                    file f      : text;
                                    f_fmt       : FixFormat_t;
                                    round       : FixRound_t    := Trunc_s;
                                    saturate    : FixSaturate_t := Warn_s);
    
    procedure cl_fix_write_bin(    a           : std_logic_vector;
                                    a_fmt       : FixFormat_t;
                                    file f      : text;
                                    f_fmt       : FixFormat_t;
                                    round       : FixRound_t    := Trunc_s;
                                    saturate    : FixSaturate_t := Warn_s
        );
    
    procedure cl_fix_write_hex(    a           : std_logic_vector;
                                    a_fmt       : FixFormat_t;
                                    file f      : text;
                                    f_fmt       : FixFormat_t;
                                    round       : FixRound_t    := Trunc_s;
                                    saturate    : FixSaturate_t := Warn_s
        );

    -----------------------------------------------------------------------------------------------
    -- Resize and Rounding
    -----------------------------------------------------------------------------------------------
    
    function cl_fix_resize(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_fix(a : std_logic_vector; a_fmt : FixFormat_t) return std_logic_vector;
    
    function cl_fix_floor(a : std_logic_vector; a_fmt : FixFormat_t) return std_logic_vector;
    
    function cl_fix_ceil(a : std_logic_vector; a_fmt : FixFormat_t) return std_logic_vector;
    
    function cl_fix_round(a : std_logic_vector; a_fmt : FixFormat_t) return std_logic_vector;
    
    function cl_fix_in_range(a : std_logic_vector; a_fmt : FixFormat_t; result_fmt : FixFormat_t; round : FixRound_t := Trunc_s) return boolean;
        
    -----------------------------------------------------------------------------------------------
    -- Math Functions
    -----------------------------------------------------------------------------------------------
    
    function cl_fix_abs(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_sabs(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_neg(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        enable      : std_logic := '1';
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_sneg(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        enable      : std_logic := '1';
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_add(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_sub(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_addsub(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        add         : std_logic;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_saddsub(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        add         : std_logic;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_mean(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_mean_angle(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        precise     : boolean;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_shift(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        shift       : integer;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_mult(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_compare(
        comparison  : string;
        a           : std_logic_vector;
        aFmt        : FixFormat_t;
        b           : std_logic_vector;
        bFmt        : FixFormat_t
    ) return boolean;
        
end package;

---------------------------------------------------------------------------------------------------
-- Package Body
---------------------------------------------------------------------------------------------------

package body en_cl_fix_pkg is

    -----------------------------------------------------------------------------------------------
    -- Internally used constants
    -----------------------------------------------------------------------------------------------
    
    subtype HexCharacter_t is string(1 to 16);
    constant HexCharacter_c : HexCharacter_t := "0123456789ABCDEF";
    
    type StdLogicCharacter_t is array(natural range <>) of character;
    constant StdLogicCharacter_c : StdLogicCharacter_t(0 to 8) := ('U', 'X', '0', '1', 'Z', 'W', 'L', 'H', '-');
        
    -----------------------------------------------------------------------------------------------
    -- Internally used functions
    -----------------------------------------------------------------------------------------------
    
    function max(a, b : integer) return integer is
    begin
        if a >= b then
            return a;
        else
            return b;
        end if;
    end;
    
    function min(a, b : integer) return integer is
    begin
        if a <= b then
            return a;
        else
            return b;
        end if;
    end;
    
    function to01(sl : std_logic) return std_logic is
        variable result_v : std_logic;
    begin
        if sl = '1' or sl = 'H' then
            result_v := '1';
        else
            result_v := '0';
        end if;
        return result_v;
    end;
    
    function toInteger(bool : boolean) return integer is
    begin
        if bool then
            return 1;
        else
            return 0;
        end if;
    end;
    
    function toLower(c : character) return character is
        variable v : character;
    begin
        case c is
            when 'A' => v := 'a';
            when 'B' => v := 'b';
            when 'C' => v := 'c';
            when 'D' => v := 'd';
            when 'E' => v := 'e';
            when 'F' => v := 'f';
            when 'G' => v := 'g';
            when 'H' => v := 'h';
            when 'I' => v := 'i';
            when 'J' => v := 'j';
            when 'K' => v := 'k';
            when 'L' => v := 'l';
            when 'M' => v := 'm';
            when 'N' => v := 'n';
            when 'O' => v := 'o';
            when 'P' => v := 'p';
            when 'Q' => v := 'q';
            when 'R' => v := 'r';
            when 'S' => v := 's';
            when 'T' => v := 't';
            when 'U' => v := 'u';
            when 'V' => v := 'v';
            when 'W' => v := 'w';
            when 'X' => v := 'x';
            when 'Y' => v := 'y';
            when 'Z' => v := 'z';
            when others => v := c;
        end case;
        return v;
    end;
    
    function toLower(s : string) return string is
        variable v : string(s'range);
    begin
        for i in s'range loop
            v(i):= toLower(s(i));
        end loop;
        return v;
    end;
    
    function string_find_next_match(Str : string; Char : character; StartIdx : natural) return integer is
        variable CurrentIdx_v       : integer := StartIdx;
        variable Match_v            : boolean := false;
        variable MatchIdx_v         : integer := -1;
    begin
        -- Checks
        assert StartIdx <= Str'high and StartIdx >= Str'low report "string_find_next_match: StartIdx out of range" severity error;
        
        -- Implementation
        while (not Match_v) and (CurrentIdx_v <= Str'high) loop
            if Str(CurrentIdx_v) = Char then
                Match_v     := true;
                MatchIdx_v  := CurrentIdx_v;
            end if;
            CurrentIdx_v := CurrentIdx_v + 1;
        end loop;
        return MatchIdx_v;
    end function;
    
    function string_find_next_match(Str : string; Pattern : string; StartIdx : natural) return integer is
        variable CurrentIdx_v       : integer := StartIdx;
        variable Match_v            : boolean := false;
        variable MatchIdx_v         : integer := -1;
    begin
        -- Checks
        assert StartIdx <= Str'high and StartIdx >= Str'low report "string_find_next_match: StartIdx out of range" severity error;
        
        -- Implementation
        while (not Match_v) and (CurrentIdx_v-1 <= Str'length-Pattern'length) loop
            Match_v     := true;
            for Idx in 1 to Pattern'length loop
                if Str(CurrentIdx_v+Idx-1) /= Pattern(Idx) then
                    Match_v := false;
                    exit;
                end if;
            end loop;
            if Match_v then
                MatchIdx_v := CurrentIdx_v;
            end if;
            CurrentIdx_v := CurrentIdx_v + 1;
        end loop;
        return MatchIdx_v;
    end function;
    
    function string_parse_boolean(Str : string; StartIdx : natural) return boolean is
            constant StrLower_c : string := toLower(Str);
            variable TrueIdx_v  : integer;
            variable FalseIdx_v : integer;
        begin
            -- Checks
            assert StartIdx <= StrLower_c'high and StartIdx >= StrLower_c'low report "en_cl_string_parse_boolean: StartIdx out of range" severity error;
            
            -- Implementation
            TrueIdx_v   := string_find_next_match(StrLower_c, "true", StartIdx);
            FalseIdx_v  := string_find_next_match(StrLower_c, "false", StartIdx);
            if TrueIdx_v = -1 then
                if FalseIdx_v = -1 then
                    report "string_parse_boolean: no boolean string found" severity error;
                    return false;
                else
                    return false;
                end if;
            elsif FalseIdx_v = -1 then
                return true;
            else
                return (TrueIdx_v < FalseIdx_v);
            end if;
    end function;
    
    function string_int_from_char(Char : character) return integer is
    begin
        case Char is
            when '0'    => return 0;
            when '1'    => return 1;
            when '2'    => return 2;
            when '3'    => return 3;
            when '4'    => return 4;
            when '5'    => return 5;
            when '6'    => return 6;
            when '7'    => return 7;
            when '8'    => return 8;
            when '9'    => return 9;
            when others => return -1;
        end case;
        return 0;
    end function;
    
    function string_char_is_numeric(Char : character) return boolean is
    begin
        return string_int_from_char(Char) /= -1;
    end function;
    
    function string_parse_int(Str : string; StartIdx : natural) return integer is
        variable CurrentIdx_v       : integer   := StartIdx;
        variable IsNegative_v       : boolean   := false;
        variable AbsoluteVal_v      : integer   := 0;
    begin
        -- Checks
        assert StartIdx <= Str'high and StartIdx >= Str'low report "string_parse_int: StartIdx out of range" severity error;
        
        -- remove leading spaces
        while Str(CurrentIdx_v) = ' ' loop
            CurrentIdx_v := CurrentIdx_v + 1;
        end loop;
        
        -- Detect negative numbers
        if Str(CurrentIdx_v) = '-' then
            IsNegative_v := true;
            CurrentIdx_v := CurrentIdx_v + 1;
        end if;
        
        -- Parse absolute value
        while (CurrentIdx_v <= Str'high) loop
            if not string_char_is_numeric(Str(CurrentIdx_v)) then
                CurrentIdx_v := Str'high+1;
            else
                AbsoluteVal_v := AbsoluteVal_v * 10 + string_int_from_char(Str(CurrentIdx_v));
                CurrentIdx_v := CurrentIdx_v + 1;
            end if;
        end loop;
        
        -- Return number with correct sign
        if IsNegative_v then
            return -AbsoluteVal_v;
        else
            return AbsoluteVal_v;
        end if;
    end function;
    
    function toString(value : std_logic_vector) return string is
        variable s          : string(1 to value'length);
        variable value_i    : std_logic_vector(value'length-1 downto 0);
    begin
        value_i := value;
        for ptr in 1 to value'length loop
            s(ptr) := StdLogicCharacter_c(std_logic'pos(value_i(value'length-ptr)));
        end loop;
        return s;
    end;
    
    function toHexString(value : std_logic_vector) return string is
        variable s          : string(1 to (value'length-1)/4+1);
        variable value_i    : bit_vector((value'length-1)/4*4+3 downto 0);
    begin
        value_i := (others => '0');
        value_i(value'length-1 downto 0) := to_bitvector(value);
        for ptr in 1 to s'length loop
            s(ptr) := HexCharacter_c(to_integer('0' & unsigned(to_stdlogicvector(
                value_i((s'length-ptr)*4+3 downto (s'length-ptr)*4)))+1));
        end loop;
        return s;
    end;
    
    -----------------------------------------------------------------------------------------------
    -- Public Functions
    -----------------------------------------------------------------------------------------------
    
    function cl_fix_format(signed : boolean; intBits : integer; fracBits : integer) return FixFormat_t is
    begin
        assert intBits + fracBits >= 1
            report "cl_fix_format : The sum of 'intBits' and 'fracBits' must be at least 1!"
            severity failure;
        
        return (signed, intBits, fracBits);
    end;
    
    function cl_fix_add_fmt(a_fmt : FixFormat_t; b_fmt : FixFormat_t) return FixFormat_t is
    begin
        return (
            a_fmt.Signed or b_fmt.Signed,
            max(a_fmt.IntBits, b_fmt.IntBits)+1,
            max(a_fmt.FracBits, b_fmt.FracBits)
        );
    end;
    
    function cl_fix_sub_fmt(a_fmt : FixFormat_t; b_fmt : FixFormat_t) return FixFormat_t is
    begin
        return (
            true,
            max(a_fmt.IntBits, b_fmt.IntBits + toInteger(b_fmt.Signed)),
            max(a_fmt.FracBits, b_fmt.FracBits)
        );
    end;
    
    function cl_fix_mult_fmt(a_fmt : FixFormat_t; b_fmt : FixFormat_t) return FixFormat_t is
        constant Signed_c   : boolean := a_fmt.Signed or b_fmt.Signed;
    begin
        return (
            Signed_c,
            a_fmt.IntBits + b_fmt.IntBits + toInteger(Signed_c),
            a_fmt.FracBits + b_fmt.FracBits
        );
    end;
    
    function cl_fix_neg_fmt(a_fmt : FixFormat_t) return FixFormat_t is
    begin
        return (
            true,
            a_fmt.IntBits + toInteger(a_fmt.Signed),
            a_fmt.FracBits
        );
    end;
    
    function cl_fix_shift_fmt(a_fmt : FixFormat_t; min_shift : integer; max_shift : integer) return FixFormat_t is
    begin
        assert min_shift <= max_shift report "min_shift must be <= max_shift" severity Failure;
        
        return (
            a_fmt.Signed,
            a_fmt.IntBits + max_shift,
            a_fmt.FracBits - min_shift
        );
    end;
    
    function cl_fix_shift_fmt(a_fmt : FixFormat_t; shift : integer) return FixFormat_t is
    begin
        return cl_fix_shift_fmt(a_fmt, shift, shift);
    end;
    
    function cl_fix_width(fmt : FixFormat_t) return positive is
    begin
        assert (fmt.IntBits+fmt.FracBits) > 0
            report "cl_fix_width : The sum of 'IntBits' and 'FracBits' must be at least 1!"
            severity failure;

        return toInteger(fmt.Signed)+fmt.IntBits+fmt.FracBits;
    end;
    
    function cl_fix_string_from_format(fmt : FixFormat_t) return string is
    begin
        return "(" & boolean'image(fmt.Signed) & "," & integer'image(fmt.IntBits) & "," & integer'image(fmt.FracBits) & ")";
    end;
    
    function cl_fix_format_from_string(Str : string) return FixFormat_t is
        variable Format_v   : FixFormat_t;
        variable Index_v    : integer;
    begin
        -- Parse Format
        Index_v := Str'low;
        Index_v := string_find_next_match(Str, '(', Index_v);
        assert Index_v > 0
            report "cl_fix_string_from_format: wrong Format, missing '('"
            severity error;
        -- Allow signedness to be specified as an integer
        if Str(Index_v+1) = '0' then
            Format_v.Signed := false;
        elsif Str(Index_v+1) = '1' then
            Format_v.Signed := true;
        else
            -- Parse signedness as boolean
            Format_v.Signed := string_parse_boolean(Str, Index_v+1);
        end if;
        Index_v := string_find_next_match(Str, ',', Index_v+1);
        assert Index_v > 0
            report "cl_fix_string_from_format: wrong Format, missing ',' between IsSigned and IntBits "
            severity error;
        Format_v.IntBits := string_parse_int(Str, Index_v+1);
        Index_v := string_find_next_match(Str, ',', Index_v+1);
        assert Index_v > 0
            report "cl_fix_string_from_format: wrong Format, missing ',' between IntBits and FracBits "
            severity error;
        Format_v.FracBits := string_parse_int(Str, Index_v+1);
        Index_v := string_find_next_match(Str, ')', Index_v+1);
        assert Index_v > 0
            report "cl_fix_string_from_format: wrong Format, missing ')'"
            severity error;
        return Format_v;
    end;
    
    function cl_fix_round_from_string(Str : string) return FixRound_t is
        constant StrLower_c : string := toLower(Str);
    begin
        if StrLower_c = "trunc_s" then
            return Trunc_s;
        elsif StrLower_c = "nonsympos_s" then
            return NonSymPos_s;
        elsif StrLower_c = "nonsymneg_s" then
            return NonSymNeg_s;
        elsif StrLower_c = "syminf_s" then
            return SymInf_s;
        elsif StrLower_c = "symzero_s" then
            return SymZero_s;
        elsif StrLower_c = "conveven_s" then
            return ConvEven_s;
        elsif StrLower_c = "convodd_s" then
            return ConvOdd_s;
        end if;
        
        report "cl_fix_round_from_string: unrecognized format " & Str severity failure;
        return Trunc_s;
    end;
    
    function cl_fix_saturate_from_string(Str : string) return FixSaturate_t is
        constant StrLower_c : string := toLower(Str);
    begin
        if StrLower_c = "none_s" then
            return None_s;
        elsif StrLower_c = "warn_s" then
            return Warn_s;
        elsif StrLower_c = "sat_s" then
            return Sat_s;
        elsif StrLower_c = "satwarn_s" then
            return SatWarn_s;
        end if;
        
        report "cl_fix_saturate_from_string: unrecognized format " & Str severity failure;
        return None_s;
    end;
    
    function cl_fix_zero_value(fmt : FixFormat_t) return std_logic_vector is
        variable result_v : std_logic_vector(cl_fix_width(fmt)-1 downto 0);
    begin
        result_v := (others => '0');
        return result_v;
    end;
    
    function cl_fix_max_value(fmt : FixFormat_t) return std_logic_vector is
        variable result_v : std_logic_vector(cl_fix_width(fmt)-1 downto 0);
    begin
        result_v := (others => '1');
        if fmt.Signed then
            result_v(result_v'high) := '0';
        end if;
        return result_v;
    end;
    
    function cl_fix_min_value(fmt : FixFormat_t) return std_logic_vector is
        variable result_v : std_logic_vector(cl_fix_width(fmt)-1 downto 0);
    begin
        if fmt.Signed then
            result_v := (others => '0');
            result_v(result_v'left) := '1';
        else
            result_v := (others => '0');
        end if;
        return result_v;
    end;
    
    function cl_fix_max_real(fmt : FixFormat_t) return real is
        variable Range_v, Lsb_v : real;
    begin
        Range_v := 2.0**fmt.IntBits;
        Lsb_v := 2.0**(-fmt.FracBits);
        return Range_v-Lsb_v;
    end function;
    
    function cl_fix_min_real(fmt : FixFormat_t)return real is
        variable Range_v : real;
    begin
        if fmt.Signed then
            Range_v := 2.0**fmt.IntBits;
            return -Range_v;
        else
            return 0.0;
        end if;
    end function;
    
    function cl_fix_sign(a : std_logic_vector; a_fmt: FixFormat_t) return std_logic is
        variable a_v : std_logic_vector(a'length-1 downto 0);
    begin
        a_v := a;
        if a_fmt.Signed then
            return a_v(a_v'high);
        else
            return '0';
        end if;
    end;
    
    function cl_fix_int(a : std_logic_vector; a_fmt : FixFormat_t) return std_logic_vector is
        variable a_v        : std_logic_vector(a'length-1 downto 0);
        variable result_v   : std_logic_vector(max(1, a_fmt.IntBits)-1 downto 0);
    begin
        a_v := a;
        result_v := (others => '0');
        if a_fmt.IntBits > 0 then
            if a_fmt.FracBits >= 0 then
                result_v(a_fmt.IntBits-1 downto 0) :=
                    a_v(a_fmt.IntBits+a_fmt.FracBits-1 downto a_fmt.FracBits);
            else
                result_v(a_fmt.IntBits-1 downto -a_fmt.FracBits) :=
                    a_v(a_fmt.IntBits-1 downto -a_fmt.FracBits);
            end if;
        end if;
        return result_v;
    end;
    
    function cl_fix_frac(a : std_logic_vector; a_fmt : FixFormat_t)
            return std_logic_vector is
        variable a_v        : std_logic_vector(a'length-1 downto 0);
        variable result_v   : std_logic_vector(max(1, a_fmt.FracBits)-1 downto 0);
    begin
        a_v := a;
        result_v := (others => '0');
        if a_fmt.FracBits > 0 then
            if a_fmt.IntBits >= 0 then
                result_v(a_fmt.FracBits-1 downto 0) :=
                    a_v(a_fmt.FracBits-1 downto 0);
            else
                result_v(a_fmt.FracBits+a_fmt.IntBits-1 downto 0) :=
                    a_v(a_fmt.FracBits+a_fmt.IntBits-1 downto 0);
            end if;
        end if;
        return result_v;
    end;
    
    function cl_fix_combine(sign : std_logic; int : std_logic_vector; frac : std_logic_vector; result_fmt : FixFormat_t) return std_logic_vector is
        variable int_v : std_logic_vector(int'length-1 downto 0);
        variable frac_v : std_logic_vector(frac'length-1 downto 0);
        variable result_v : std_logic_vector(cl_fix_width(result_fmt)-1 downto 0);
    begin
        int_v := int;
        frac_v := frac;
        result_v := (others => '0');
        if result_fmt.Signed then
            if result_fmt.IntBits > 0 then
                if result_fmt.FracBits > 0 then
                    result_v := sign & int_v(result_fmt.IntBits-1 downto 0) &
                        frac_v(result_fmt.FracBits-1 downto 0);
                else
                    result_v := sign & int_v(result_fmt.IntBits-1 downto -result_fmt.FracBits);
                end if;
            else
                result_v := sign & frac_v(result_fmt.FracBits+result_fmt.IntBits-1 downto 0);
            end if;
        else
            assert sign = '0'
                report "cl_fix_combine : sign may not be set for an unsigned format!"
                severity failure;
            if result_fmt.IntBits > 0 then
                if result_fmt.FracBits > 0 then
                    result_v := int_v(result_fmt.IntBits-1 downto 0) &
                        frac_v(result_fmt.FracBits-1 downto 0);
                else
                    result_v := int_v(result_fmt.IntBits-1 downto -result_fmt.FracBits);
                end if;
            else
                result_v := frac_v(result_fmt.FracBits+result_fmt.IntBits-1 downto 0);
            end if;
        end if;
        return result_v;
    end;
    
    function cl_fix_get_msb(a : std_logic_vector; a_fmt : FixFormat_t; index : natural) return std_logic is
    begin
        return a(a'high-index);
    end;
    
    function cl_fix_get_lsb(a : std_logic_vector; a_fmt : FixFormat_t; index : natural) return std_logic is
    begin
        return a(index);
    end;
    
    function cl_fix_set_msb(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        index       : natural;
        value       : std_logic
    ) return std_logic_vector is
        variable a_v : std_logic_vector(a'length-1 downto 0);
    begin
        a_v := a;
        a_v(a_v'high-index) := value;
        return a_v;
    end;
    
    function cl_fix_set_lsb(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        index       : natural;
        value       : std_logic
    ) return std_logic_vector is
        variable a_v : std_logic_vector(a'length-1 downto 0);
    begin
        a_v := a;
        a_v(index) := value;
        return a_v;
    end;
    
    function cl_fix_from_int(a : integer; result_fmt : FixFormat_t; saturate : FixSaturate_t := SatWarn_s) return std_logic_vector is
        variable a_v        : integer;
        variable result_v   : std_logic_vector(cl_fix_width(result_fmt)-1 downto 0);
    begin
        result_v := (others => '0');
        a_v := a;
        if result_fmt.Signed then
            assert not ((saturate = Warn_s or saturate = SatWarn_s) and
                    (a_v >= 2**result_fmt.IntBits or a_v < -2**result_fmt.IntBits))
                report "cl_fix_from_int : Saturation Warning!"
                severity warning;
            if saturate = Sat_s or saturate = SatWarn_s then
                a_v := max(min(a_v, 2**result_fmt.IntBits-1), -2**result_fmt.IntBits);
            end if;
            result_v(result_v'high downto result_fmt.FracBits) :=
                std_logic_vector(to_signed(a_v, result_fmt.IntBits+1));
        else
            assert not ((saturate = Warn_s or saturate = SatWarn_s) and (a_v >= 2**result_fmt.IntBits or a_v < 0))
                report "cl_fix_from_int : Saturation Warning!"
                severity warning;
            if saturate = Sat_s or saturate = SatWarn_s then
                a_v := max(min(a_v, 2**result_fmt.IntBits-1), 0);
            end if;
            result_v(result_v'high downto result_fmt.FracBits) :=
                std_logic_vector(to_unsigned(a_v, result_fmt.IntBits));
        end if;
        return result_v;
    end;
    
    function cl_fix_to_int(a : std_logic_vector; a_fmt : FixFormat_t) return integer is
        variable a_v : std_logic_vector(a'length-1 downto 0);
    begin
        a_v := a;
        -- TODO: range check on a!
        if a_fmt.Signed then
            if a_fmt.IntBits > 0 then
                if a_fmt.FracBits >= 0 then
                    return to_integer(signed(a_v(a_v'high downto a_fmt.FracBits)));
                else
                    return to_integer(signed(a_v)) * 2**(-a_fmt.FracBits);
                end if;
            else
                return 0;
            end if;
        else
            if a_fmt.IntBits > 0 then
                if a_fmt.FracBits >= 0 then
                    return to_integer(unsigned(a_v(a_v'high downto a_fmt.FracBits)));
                else
                    return to_integer(unsigned(a_v)) * 2**(-a_fmt.FracBits);
                end if;
            else
                return 0;
            end if;
        end if;
    end;
    
    function cl_fix_from_real(a : real; result_fmt : FixFormat_t; saturate : FixSaturate_t := SatWarn_s) return std_logic_vector is
        constant ChunkSize_c    : positive := 30;
        constant ChunkCount_c   : positive := (cl_fix_width(result_fmt) + ChunkSize_c - 1)/ChunkSize_c;
        variable ASat_v         : real;
        variable Chunk_v        : std_logic_vector(ChunkSize_c-1 downto 0);
        variable Result_v       : std_logic_vector(ChunkSize_c*ChunkCount_c-1 downto 0);
    begin
        -- Limit
        if a > cl_fix_max_real(result_fmt) then
            ASat_v := cl_fix_max_real(result_fmt);
        elsif a < cl_fix_min_real(result_fmt) then
            ASat_v := cl_fix_min_real(result_fmt);
        else
            ASat_v := a;
        end if;
        
        -- Rescale to appropriate fractional bits
        ASat_v := round(ASat_v * 2.0**(result_fmt.FracBits));
        
        -- Convert to fixed-point in chunks
        for i in 0 to ChunkCount_c-1 loop
            -- Note: Due to a Xilinx Vivado bug, we must explicitly call the math_real mod operator
            Chunk_v := std_logic_vector(to_unsigned(integer(ieee.math_real."mod"(ASat_v, 2.0**ChunkSize_c)), ChunkSize_c));
            Result_v((i+1)*ChunkSize_c-1 downto i*ChunkSize_c) := Chunk_v;
            ASat_v := floor(ASat_v/2.0**ChunkSize_c);
        end loop;
        
        return Result_v(cl_fix_width(result_fmt)-1 downto 0);
    end;
    
    function cl_fix_to_real(a : std_logic_vector; a_fmt : FixFormat_t) return real is
        constant ABits_c        : positive := cl_fix_width(a_fmt);
        constant ChunkSize_c    : positive := 30;
        constant ChunkCount_c   : positive := (ABits_c + ChunkSize_c - 1)/ChunkSize_c;
        variable a_v            : std_logic_vector(a'length-1 downto 0);
        variable Correction_v   : real := 0.0;
        variable apad_v         : unsigned(ChunkSize_c*ChunkCount_c-1 downto 0);
        variable Chunk_v        : unsigned(ChunkSize_c-1 downto 0);
        variable result_v       : real := 0.0;
    begin
        -- Enforce 'downto' bit order
        a_v := a;
        
        -- Handle sign bit
        if a_fmt.Signed and a_v(ABits_c-1) = '1' then
            a_v(ABits_c-1) := '0'; -- Clear sign bit.
            Correction_v := -2.0**(ABits_c-1 - a_fmt.FracBits); -- Remember its weight.
        end if;
        
        -- Resize to an integer number of chunks
        apad_v := resize(unsigned(a_v), ChunkSize_c*ChunkCount_c);
        
        -- Convert to real in chunks
        for i in ChunkCount_c-1 downto 0 loop
            result_v := result_v * 2.0**ChunkSize_c; -- Shift to next chunk.
            Chunk_v := apad_v((i+1)*ChunkSize_c-1 downto i*ChunkSize_c);
            result_v := result_v + real(to_integer(Chunk_v)) * 2.0**(-a_fmt.FracBits);
        end loop;
        
        -- Add sign bit contribution
        result_v := result_v + Correction_v;
        
        return result_v;
    end;
    
    function cl_fix_from_bin(a : string; result_fmt : FixFormat_t) return std_logic_vector is
        variable a_v : string(1 to a'length);
        variable result_v : std_logic_vector(a'length-1 downto 0);
        variable pos_v : natural;
    begin
        a_v := a;
        pos_v := a'length;
        for i in 1 to a'length loop
            case a_v(i) is
            when '0' =>
                pos_v := pos_v - 1;
                result_v(pos_v) := '0';
            when '1' =>
                pos_v := pos_v - 1;
                result_v(pos_v) := '1';
            when 'b' | 'B'  =>
                if i = 2 and a_v(1) = '0' then
                    pos_v := a'length;
                end if;
            when '_' =>
            when others =>
                report "cl_fix_from_bin : Illegal character in binary string!"
                    severity error;
            end case;
        end loop;
        assert a'length-pos_v = cl_fix_width(result_fmt);
            report "cl_fix_from_bin : The binary string doesn't have the correct length!"
            severity error;
        return result_v(a'length-1 downto pos_v);
    end;
    
    function cl_fix_to_bin(a : std_logic_vector; a_fmt : FixFormat_t) return string is
    begin
        return toString(a);
    end;
    
    function cl_fix_from_hex(a : string; result_fmt : FixFormat_t) return std_logic_vector is
        constant ResultWidth_c : positive := cl_fix_width(result_fmt);
        variable a_v : string(1 to a'length);
        variable result_v : std_logic_vector(a'length*4-1 downto 0);
        variable pos_v : natural;
    begin
        a_v := a;
        pos_v := a'length;
        for i in 1 to a_v'length loop
            case a_v(i) is
            when '0'        => result_v(pos_v*4+3 downto pos_v*4) := "0000"; pos_v := pos_v - 1;
            when '1'        => result_v(pos_v*4+3 downto pos_v*4) := "0001"; pos_v := pos_v - 1;
            when '2'        => result_v(pos_v*4+3 downto pos_v*4) := "0010"; pos_v := pos_v - 1;
            when '3'        => result_v(pos_v*4+3 downto pos_v*4) := "0011"; pos_v := pos_v - 1;
            when '4'        => result_v(pos_v*4+3 downto pos_v*4) := "0100"; pos_v := pos_v - 1;
            when '5'        => result_v(pos_v*4+3 downto pos_v*4) := "0101"; pos_v := pos_v - 1;
            when '6'        => result_v(pos_v*4+3 downto pos_v*4) := "0110"; pos_v := pos_v - 1;
            when '7'        => result_v(pos_v*4+3 downto pos_v*4) := "0111"; pos_v := pos_v - 1;
            when '8'        => result_v(pos_v*4+3 downto pos_v*4) := "1000"; pos_v := pos_v - 1;
            when '9'        => result_v(pos_v*4+3 downto pos_v*4) := "1001"; pos_v := pos_v - 1;
            when 'a' | 'A'  => result_v(pos_v*4+3 downto pos_v*4) := "1010"; pos_v := pos_v - 1;
            when 'b' | 'B'  => result_v(pos_v*4+3 downto pos_v*4) := "1011"; pos_v := pos_v - 1;
            when 'c' | 'C'  => result_v(pos_v*4+3 downto pos_v*4) := "1100"; pos_v := pos_v - 1;
            when 'd' | 'D'  => result_v(pos_v*4+3 downto pos_v*4) := "1101"; pos_v := pos_v - 1;
            when 'e' | 'E'  => result_v(pos_v*4+3 downto pos_v*4) := "1110"; pos_v := pos_v - 1;
            when 'f' | 'F'  => result_v(pos_v*4+3 downto pos_v*4) := "1111"; pos_v := pos_v - 1;
            when 'x' | 'X'  =>
                if i = 2 and a_v(1) = '0' then
                    pos_v := a'length;
                end if;
            when '_' =>
            when others =>
                report "cl_fix_from_hex : Illegal character in hexadecimal string!"
                    severity error;
            end case;
        end loop;
        assert 4*(a'length-pos_v) >= ResultWidth_c and 4*(a'length-pos_v-1) < ResultWidth_c;
            report "cl_fix_from_hex : The hexadecimal string doesn't have the correct length!"
            severity error;
        if ResultWidth_c/4*4 < ResultWidth_c then
            assert unsigned(result_v(a'length*4-1 downto pos_v*4+ResultWidth_c)) = 0
                report "cl_fix_from_hex : The unused bits in the hexadecimal string are not all equal to zero!"
                severity error;
        end if;
        return result_v(pos_v*4+ResultWidth_c-1 downto pos_v*4);
    end;
    
    function cl_fix_to_hex(a : std_logic_vector; a_fmt : FixFormat_t) return string is
    begin
        return toHexString(a);
    end;
    
    function cl_fix_from_bits_as_int(a : integer; aFmt : FixFormat_t) return std_logic_vector is
    begin
        if aFmt.Signed then
            return std_logic_vector(to_signed(a, cl_fix_width(aFmt)));
        else
            return std_logic_vector(to_unsigned(a, cl_fix_width(aFmt)));
        end if;
    end function;
    
    function cl_fix_get_bits_as_int(a : std_logic_vector; aFmt : FixFormat_t) return integer is
    begin
        if aFmt.Signed then
            return to_integer(signed(a));
        else
            return to_integer(unsigned(a));
        end if;
    end function;
    
    impure function cl_fix_read_int(   file a      : text;
                                        result_fmt  : FixFormat_t;
                                        saturate    : FixSaturate_t := SatWarn_s)
                                        return std_logic_vector is
        constant TempFmt_c  : FixFormat_t :=
            (
                Signed      => result_fmt.Signed,
                IntBits     => result_fmt.IntBits+result_fmt.FracBits,
                FracBits    => 0
            );
        variable line_v     : line;
        variable ok_v       : boolean;
        variable temp_v     : integer;
        variable result_v   : std_logic_vector(cl_fix_width(result_fmt)-1 downto 0);
    begin
        readline(a, line_v);
        read(line_v, temp_v, ok_v);
        if ok_v then
            result_v := cl_fix_from_int(temp_v, TempFmt_c, saturate);
        else
            assert false
                report "cl_fix_read_int : Could not read from stimuli file!"
                severity error;
        end if;
        return result_v;
    end;
    
    impure function cl_fix_read_real(  file a      : text;
                                        result_fmt  : FixFormat_t;
                                        saturate    : FixSaturate_t := SatWarn_s)
                                        return std_logic_vector is
        variable line_v     : line;
        variable ok_v       : boolean;
        variable temp_v     : real;
        variable result_v   : std_logic_vector(cl_fix_width(result_fmt)-1 downto 0);
    begin
        readline(a, line_v);
        read(line_v, temp_v, ok_v);
        if ok_v then
            result_v := cl_fix_from_real(temp_v, result_fmt, saturate);
        else
            assert false
                report "cl_fix_read_real : Could not read from stimuli fil\EB!"
                severity error;
        end if;
        return result_v;
    end;
    
    impure function cl_fix_read_bin(   file a      : text;
                                        result_fmt  : FixFormat_t)
                                        return std_logic_vector is
        variable line_v     : line;
        variable ok_v       : boolean;
        variable temp_v     : string(cl_fix_width(result_fmt) downto 1);
        variable result_v   : std_logic_vector(cl_fix_width(result_fmt)-1 downto 0);
    begin
        readline(a, line_v);
        read(line_v, temp_v, ok_v);
        if ok_v then
            result_v := cl_fix_from_bin(temp_v, result_fmt);
        else
            assert false
                report "cl_fix_read_bin : Could not read from stimuli fil\EB!"
                severity error;
        end if;
        return result_v;
    end;
    
    impure function cl_fix_read_hex(   file a      : text;
                                        result_fmt  : FixFormat_t)
                                        return std_logic_vector is
        variable line_v     : line;
        variable ok_v       : boolean;
        variable temp_v     : string(cl_fix_width(result_fmt) downto 1);
        variable result_v   : std_logic_vector(cl_fix_width(result_fmt)-1 downto 0);
    begin
        readline(a, line_v);
        read(line_v, temp_v, ok_v);
        if ok_v then
            result_v := cl_fix_from_hex(temp_v, result_fmt);
        else
            assert false
                report "cl_fix_read_hex : Could not read from stimuli fil\EB!"
                severity error;
        end if;
        return result_v;
    end;
    
    procedure cl_fix_write_int(    a           : std_logic_vector;
                                    a_fmt       : FixFormat_t;
                                    file f      : text;
                                    f_fmt       : FixFormat_t;
                                    round       : FixRound_t    := Trunc_s;
                                    saturate    : FixSaturate_t := Warn_s) is
        variable line_v     : line;
        variable temp_v     : integer;
        variable f_v        : std_logic_vector(cl_fix_width(f_fmt)-1 downto 0);
    begin
        f_v := cl_fix_resize(a, a_fmt, f_fmt, round, saturate);
        if f_fmt.Signed then
            temp_v  := to_integer(signed(f_v));
        else
            temp_v  := to_integer(unsigned(f_v));
        end if;
        write(line_v, temp_v);
        writeline(f, line_v);
    end;
    
    procedure cl_fix_write_real(   a           : std_logic_vector;
                                    a_fmt       : FixFormat_t;
                                    file f      : text;
                                    f_fmt       : FixFormat_t;
                                    round       : FixRound_t    := Trunc_s;
                                    saturate    : FixSaturate_t := Warn_s) is
        variable line_v     : line;
        variable temp_v     : real;
        variable f_v        : std_logic_vector(cl_fix_width(f_fmt)-1 downto 0);
    begin
        f_v := cl_fix_resize(a, a_fmt, f_fmt, round, saturate);
        temp_v  := cl_fix_to_real(f_v, f_fmt);
        write(line_v, real'image(temp_v));
        writeline(f, line_v);
    end;
    
    procedure cl_fix_write_bin(    a           : std_logic_vector;
                                    a_fmt       : FixFormat_t;
                                    file f      : text;
                                    f_fmt       : FixFormat_t;
                                    round       : FixRound_t    := Trunc_s;
                                    saturate    : FixSaturate_t := Warn_s) is
        variable line_v     : line;
        variable temp_v     : string(1 to cl_fix_width(f_fmt));
        variable f_v        : std_logic_vector(cl_fix_width(f_fmt)-1 downto 0);
    begin
        f_v := cl_fix_resize(a, a_fmt, f_fmt, round, saturate);
        temp_v  := cl_fix_to_bin(f_v, f_fmt);
        write(line_v, temp_v);
        writeline(f, line_v);
    end;
    
    procedure cl_fix_write_hex(    a           : std_logic_vector;
                                    a_fmt       : FixFormat_t;
                                    file f      : text;
                                    f_fmt       : FixFormat_t;
                                    round       : FixRound_t    := Trunc_s;
                                    saturate    : FixSaturate_t := Warn_s) is
        variable line_v     : line;
        variable temp_v     : string(1 to (cl_fix_width(a_fmt)-1)/4+1);
        variable f_v        : std_logic_vector(cl_fix_width(f_fmt)-1 downto 0);
    begin
        f_v := cl_fix_resize(a, a_fmt, f_fmt, round, saturate);
        temp_v  := cl_fix_to_hex(f_v, f_fmt);
        write(line_v, temp_v);
        writeline(f, line_v);
    end;
    
    function cl_fix_resize(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t    := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        constant DropFracBits_c     : integer := a_fmt.FracBits - result_fmt.FracBits;
        constant NeedRound_c        : boolean := round /= Trunc_s and DropFracBits_c > 0;
        -- Rounding addition is performed with an additional integer bit (carry bit)
        constant CarryBit_c         : boolean := NeedRound_c and saturate /= None_s;
        -- It is not clear what this extra bit is for (undocumented)
        constant AddSignBit_c       : boolean := ((a_fmt.Signed = false) and (result_fmt.Signed = false) and (saturate /= None_s));
        -- Several rounding methods use the largest value smaller than the tie weight ("half").
        -- The required integer value is 2**(DropFracBits_c-1)-1, but to support >32 bits, we use unsigned.
        function GetHalfMinusDelta return unsigned is
        begin
            -- If DropFracBits_c = 1, then 2**(DropFracBits_c-1)-1 = 0.
            -- If DropFracBits_c < 1, then NeedRound_c = FALSE, so the value is never used (just return 0).
            if DropFracBits_c <= 1 then
                return "0";
            end if;
            -- If DropFracBits_c > 1 then 2**(DropFracBits_c-1)-1 = "11...1"
            return (DropFracBits_c-2 downto 0 => '1');
        end function;
        
        constant HalfMinusDelta_c   : unsigned := GetHalfMinusDelta;
        constant TempFmt_c : FixFormat_t :=
            (
                Signed      => a_fmt.Signed or result_fmt.Signed, -- must stay like this!
                IntBits     => max(a_fmt.IntBits + toInteger(CarryBit_c), result_fmt.IntBits) + toInteger(AddSignBit_c),
                FracBits    => max(a_fmt.FracBits, result_fmt.FracBits)
            );
        constant TempWidth_c        : positive := cl_fix_width(TempFmt_c);
        constant ResultWidth_c      : positive := cl_fix_width(result_fmt);
        constant MoreFracBits_c     : natural := TempFmt_c.FracBits - a_fmt.FracBits;
        constant CutFracBits_c      : natural := TempFmt_c.FracBits - result_fmt.FracBits;
        constant CutIntSignBits_c   : integer := TempWidth_c - (ResultWidth_c+CutFracBits_c);
        
        variable a_v        : std_logic_vector(a'length-1 downto 0);
        variable temp_v     : unsigned(TempWidth_c-1 downto 0);
        variable sign_v     : std_logic;
        variable result_v   : std_logic_vector(ResultWidth_c-1 downto 0);
    begin
        -- TODO: Rounding addition could be less wide when result_fmt.IntBits > a_fmt.IntWidth
        -- TODO: saturate = Warn_s could use no carry bit for synthesis.
        a_v := a;
        temp_v := (others => '0');
        if a_fmt.Signed then
            temp_v(temp_v'high downto MoreFracBits_c) := unsigned(resize(signed(a_v), TempWidth_c-MoreFracBits_c));
        else
            temp_v(temp_v'high downto MoreFracBits_c) := resize(unsigned(a_v), TempWidth_c-MoreFracBits_c);
        end if;
        if NeedRound_c then -- rounding required
            if a_fmt.Signed then
                sign_v := a_v(a_v'high);
            else
                sign_v := '0';
            end if;
            case round is
                when Trunc_s        => null;
                when NonSymPos_s    => temp_v(TempWidth_c-1 downto DropFracBits_c-1) := temp_v(TempWidth_c-1 downto DropFracBits_c-1) + 1;
                when NonSymNeg_s    => temp_v := temp_v + HalfMinusDelta_c;
                when SymInf_s       => temp_v := temp_v + HalfMinusDelta_c + ("" & not sign_v);
                when SymZero_s      => temp_v := temp_v + HalfMinusDelta_c + ("" & sign_v);
                when ConvEven_s     =>
                    if DropFracBits_c < a_v'length then
                        temp_v := temp_v + HalfMinusDelta_c + ("" & a_v(DropFracBits_c));
                    else
                        temp_v := temp_v + HalfMinusDelta_c + ("" & sign_v); -- implicit sign extension
                    end if;
                when ConvOdd_s      =>
                    if DropFracBits_c < a_v'length then
                        temp_v := temp_v + HalfMinusDelta_c + ("" & not a_v(DropFracBits_c));
                    else
                        temp_v := temp_v + HalfMinusDelta_c + ("" & not sign_v); -- implicit sign extension
                    end if;
            end case;
        end if;
        if CutIntSignBits_c > 0 and saturate /= None_s then -- saturation required
            if result_fmt.Signed then -- signed output
                if to_01(temp_v(temp_v'high downto temp_v'high-CutIntSignBits_c)) /= 0 and
                        not temp_v(temp_v'high downto temp_v'high-CutIntSignBits_c) /= 0 then
                    assert saturate = Sat_s report "cl_fix_resize : Saturation Warning!" severity warning;
                    if saturate /= Warn_s then
                        temp_v(temp_v'high-1 downto 0) := (others => not temp_v(temp_v'high));
                        temp_v(ResultWidth_c+CutFracBits_c-1) := temp_v(temp_v'high);
                    end if;
                end if;
            else -- unsigned output
                if to_01(temp_v(temp_v'high downto temp_v'high-CutIntSignBits_c+1)) /= 0 then
                    assert saturate = Sat_s report "cl_fix_resize : Saturation Warning!" severity warning;
                    if saturate /= Warn_s then
                        temp_v := (others => not temp_v(temp_v'high));
                    end if;
                end if;
            end if;
        end if;
        result_v := std_logic_vector(temp_v(ResultWidth_c+CutFracBits_c-1 downto CutFracBits_c));
        return result_v;
    end;
    
    function cl_fix_fix(a : std_logic_vector; a_fmt : FixFormat_t) return std_logic_vector is
        constant ResultFmt_c    : FixFormat_t :=
                                                (
                                                    Signed      => a_fmt.Signed,
                                                    IntBits     => a_fmt.IntBits,
                                                    FracBits    => 0
                                                );
    begin
        return cl_fix_resize(a, a_fmt, ResultFmt_c, SymZero_s, None_s);
    end;
    
    function cl_fix_floor(a : std_logic_vector; a_fmt : FixFormat_t) return std_logic_vector is
        constant ResultFmt_c    : FixFormat_t :=
            (
                Signed      => a_fmt.Signed,
                IntBits     => a_fmt.IntBits,
                FracBits    => 0
            );
    begin
        return cl_fix_resize(a, a_fmt, ResultFmt_c, NonSymNeg_s, None_s);
    end;
    
    function cl_fix_ceil(a : std_logic_vector; a_fmt : FixFormat_t) return std_logic_vector is
        constant ResultFmt_c    : FixFormat_t :=
            (
                Signed      => a_fmt.Signed,
                IntBits     => a_fmt.IntBits,
                FracBits    => 0
            );
    begin
        return cl_fix_resize(a, a_fmt, ResultFmt_c, NonSymPos_s, None_s);
    end;
    
    function cl_fix_round(a : std_logic_vector; a_fmt : FixFormat_t) return std_logic_vector is
        constant ResultFmt_c    : FixFormat_t :=
            (
                Signed      => a_fmt.Signed,
                IntBits     => a_fmt.IntBits,
                FracBits    => 0
            );
    begin
        return cl_fix_resize(a, a_fmt, ResultFmt_c, SymInf_s, None_s);
    end;
    
    function cl_fix_in_range(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s
    ) return boolean is
        -- Note: This matches the python implementation
        constant rndFmt_c : FixFormat_t :=
            (
                Signed      => a_fmt.Signed,
                IntBits     => a_fmt.IntBits + 1,
                FracBits    => result_fmt.FracBits
            );
        
        -- Apply rounding
        constant Rounded_c  : std_logic_vector := cl_fix_resize(a, a_fmt, rndFmt_c, round, Sat_s);
    begin
        return cl_fix_compare("a>=b", Rounded_c, rndFmt_c, cl_fix_min_value(result_fmt), result_fmt) and
               cl_fix_compare("a<=b", Rounded_c, rndFmt_c, cl_fix_max_value(result_fmt), result_fmt);
    end;
    
    function cl_fix_abs(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        constant TempFmt_c  : FixFormat_t :=
            (
                Signed      => a_fmt.Signed,
                IntBits     => a_fmt.IntBits+toInteger(a_fmt.Signed),
                FracBits    => a_fmt.FracBits
            );
        variable a_v        : std_logic_vector(a'length-1 downto 0);
        variable temp_v     : std_logic_vector(cl_fix_width(TempFmt_c)-1 downto 0);
    begin
        a_v := a;
        if a_fmt.Signed then
            temp_v := a_v(a_v'high) & a_v;
            if a_v(a_v'high) = '1' then
                temp_v := std_logic_vector(unsigned(not temp_v) + 1);
            end if;
        else
            temp_v := a_v;
        end if;
        return cl_fix_resize(temp_v, TempFmt_c, result_fmt, round, saturate);
    end;
    
    function cl_fix_sabs(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        constant TempFmt_c  : FixFormat_t :=
            (
                Signed      => a_fmt.Signed,
                IntBits     => a_fmt.IntBits,
                FracBits    => max(a_fmt.FracBits, result_fmt.FracBits)
            );
        variable a_v        : std_logic_vector(a'length-1 downto 0);
        variable temp_v     : std_logic_vector(cl_fix_width(TempFmt_c)-1 downto 0);
        variable result_v   : std_logic_vector(cl_fix_width(result_fmt)-1 downto 0);
    begin
        if a_fmt.Signed then
            temp_v := cl_fix_resize(a, a_fmt, TempFmt_c, Trunc_s, None_s);
            if temp_v(temp_v'high) = '1' then
                temp_v := not temp_v;
            end if;
            result_v := cl_fix_resize(temp_v, TempFmt_c, result_fmt, round, saturate);
        else
            result_v := cl_fix_resize(a, a_fmt, result_fmt, round, saturate);
        end if;
        return result_v;
    end;
    
    function cl_fix_neg(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        enable      : std_logic := '1';
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        constant AFullFmt_c : FixFormat_t := (true, a_fmt.IntBits+ toInteger(a_fmt.Signed), a_fmt.FracBits);
        variable AFull_v    : std_logic_vector(cl_fix_width(AFullFmt_c)-1 downto 0);
        variable Neg_v      : std_logic_vector(cl_fix_width(AFullFmt_c)-1 downto 0);
    begin
        AFull_v := cl_fix_resize(a, a_fmt, AFullFmt_c);
        Neg_v   := std_logic_vector(-signed(AFull_v));
        return cl_fix_resize(Neg_v, AFullFmt_c, result_fmt, round, saturate);
    end;
    
    function cl_fix_sneg(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        enable      : std_logic := '1';
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        constant TempFmt_c  : FixFormat_t :=
            (
                Signed      => a_fmt.Signed,
                IntBits     => a_fmt.IntBits,
                FracBits    => max(a_fmt.FracBits, result_fmt.FracBits)
            );
        variable a_v        : std_logic_vector(a'length-1 downto 0);
        variable temp_v     : std_logic_vector(cl_fix_width(TempFmt_c)-1 downto 0);
        variable result_v   : std_logic_vector(cl_fix_width(result_fmt)-1 downto 0);
    begin
        assert a_fmt.Signed
            report "cl_fix_sneg : Cannot negate an unsigned value."
            severity failure;

        temp_v := cl_fix_resize(a, a_fmt, TempFmt_c, Trunc_s, None_s);
        if to01(enable) = '1' then
            temp_v := not temp_v;
        end if;
        result_v := cl_fix_resize(temp_v, TempFmt_c, result_fmt, round, saturate);
        return result_v;
    end;
    
    function cl_fix_addsub_internal(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        add         : std_logic
    ) return std_logic_vector is
        constant IsSigned_c : boolean := a_fmt.Signed or b_fmt.Signed;
        variable result_v   : std_logic_vector(a'range);
    begin
        -- Synthesis tools may create problems if correct signed/unsigned type
        -- is not used for addition.
        if to01(add) = '1' then
            if IsSigned_c then
                result_v := std_logic_vector(  signed(a) +   signed(b));
            else
                result_v := std_logic_vector(unsigned(a) + unsigned(b));
            end if;
        else
            if IsSigned_c then
                result_v := std_logic_vector(  signed(a) -   signed(b));
            else
                result_v := std_logic_vector(unsigned(a) - unsigned(b));
            end if;
        end if;
        return result_v;
    end function;
    
    function cl_fix_add(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        constant CarryBit_c : boolean := -- addition performed with an additional integer bit
            result_fmt.IntBits > max(a_fmt.IntBits, b_fmt.IntBits) or (saturate = Sat_s or
        -- synthesis translate_off
            saturate = Warn_s or
        -- synthesis translate_on
            saturate = SatWarn_s);
            -- TODO: CarryBit in cl_fix_resize not needed in all cases
        constant TempFmt_c  : FixFormat_t :=
            (
                Signed      => a_fmt.Signed or b_fmt.Signed,
                IntBits     => max(a_fmt.IntBits, b_fmt.IntBits) + toInteger(CarryBit_c),
                FracBits    => max(a_fmt.FracBits, b_fmt.FracBits)
            );
        constant TempWidth_c: positive := cl_fix_width(TempFmt_c);
        variable a_v        : std_logic_vector(TempWidth_c-1 downto 0);
        variable b_v        : std_logic_vector(TempWidth_c-1 downto 0);
        variable temp_v     : std_logic_vector(TempWidth_c-1 downto 0);
        variable result_v   : std_logic_vector(cl_fix_width(result_fmt)-1 downto 0);
    begin
        a_v := cl_fix_resize(a, a_fmt, TempFmt_c, Trunc_s, None_s);
        b_v := cl_fix_resize(b, b_fmt, TempFmt_c, Trunc_s, None_s);
        temp_v := cl_fix_addsub_internal(a_v, a_fmt, b_v, b_fmt, '1');
        result_v := cl_fix_resize(temp_v, TempFmt_c, result_fmt, round, saturate);
        return result_v;
    end;
    
    function cl_fix_sub(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        constant Saturate_c : boolean := (saturate = Sat_s or
        -- synthesis translate_off
            saturate = Warn_s or
        -- synthesis translate_on
            saturate = SatWarn_s);
        constant Grow_c     : boolean := result_fmt.IntBits > max(a_fmt.IntBits, b_fmt.IntBits);
        -- Use correct signed/unsigned type for subtraction (else synthesis tools can cause problems)
        constant SubFmt_c   : FixFormat_t :=
            (
                Signed      => a_fmt.Signed or b_fmt.Signed,
                IntBits     => max(a_fmt.IntBits, b_fmt.IntBits) + toInteger(Grow_c or Saturate_c),
                FracBits    => max(a_fmt.FracBits, b_fmt.FracBits)
            );
        -- Switch to signed for final resize if saturating
        constant ReszFmt_c  : FixFormat_t :=
            (
                Signed      => SubFmt_c.Signed or Saturate_c,
                IntBits     => SubFmt_c.IntBits,
                FracBits    => SubFmt_c.FracBits
            );
        constant SubWidth_c : positive := cl_fix_width(SubFmt_c);
        variable a_v        : std_logic_vector(SubWidth_c-1 downto 0);
        variable b_v        : std_logic_vector(SubWidth_c-1 downto 0);
        variable temp_v     : std_logic_vector(SubWidth_c-1 downto 0);
        variable result_v   : std_logic_vector(cl_fix_width(result_fmt)-1 downto 0);
    begin
        a_v := cl_fix_resize(a, a_fmt, SubFmt_c, Trunc_s, None_s);
        b_v := cl_fix_resize(b, b_fmt, SubFmt_c, Trunc_s, None_s);
        temp_v := cl_fix_addsub_internal(a_v, a_fmt, b_v, b_fmt, '0');
        result_v := cl_fix_resize(temp_v, ReszFmt_c, result_fmt, round, saturate);
        return result_v;
    end;
    
    function cl_fix_addsub(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        add         : std_logic;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        variable result_v   : std_logic_vector(cl_fix_width(result_fmt)-1 downto 0);
    begin
        if to01(add) = '1' then
            result_v := cl_fix_add(a, a_fmt, b, b_fmt, result_fmt, round, saturate);
        else
            result_v := cl_fix_sub(a, a_fmt, b, b_fmt, result_fmt, round, saturate);
        end if;
        return result_v;
    end;
    
    function cl_fix_saddsub(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        add         : std_logic;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        constant CarryBit_c : boolean := -- addition performed with an additional integer bit
            result_fmt.IntBits > max(a_fmt.IntBits, b_fmt.IntBits) or (saturate = Sat_s or
        -- synthesis translate_off
            saturate = Warn_s or
        -- synthesis translate_on
            saturate = SatWarn_s);
        constant TempFmt_c  : FixFormat_t :=
            (
                Signed      => a_fmt.Signed or b_fmt.Signed,
                IntBits     => max(a_fmt.IntBits, b_fmt.IntBits) + toInteger(CarryBit_c),
                FracBits    => max(a_fmt.FracBits, b_fmt.FracBits)
            );
        constant TempWidth_c: positive := cl_fix_width(TempFmt_c);
        variable a_v        : std_logic_vector(TempWidth_c-1 downto 0);
        variable b_v        : std_logic_vector(TempWidth_c-1 downto 0);
        variable temp_v     : std_logic_vector(TempWidth_c-1 downto 0);
        variable result_v   : std_logic_vector(cl_fix_width(result_fmt)-1 downto 0);
    begin
        a_v := cl_fix_resize(a, a_fmt, TempFmt_c, Trunc_s, None_s);
        b_v := cl_fix_resize(b, b_fmt, TempFmt_c, Trunc_s, None_s);
        if to01(add) = '0' then
            b_v := not b_v;
        end if;
        temp_v := cl_fix_addsub_internal(a_v, a_fmt, b_v, b_fmt, '1');
        result_v := cl_fix_resize(temp_v, TempFmt_c, result_fmt, round, saturate);
        return result_v;
    end;
    
    function cl_fix_mean(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        constant TempFmt_c  : FixFormat_t :=
            (
                Signed      => a_fmt.Signed or b_fmt.Signed,
                IntBits     => max(a_fmt.IntBits, b_fmt.IntBits) + 1,
                FracBits    => max(a_fmt.FracBits, b_fmt.FracBits)
            );
        constant TempWidth_c: positive := cl_fix_width(TempFmt_c);
        variable temp_v     : std_logic_vector(TempWidth_c-1 downto 0);
        variable result_v   : std_logic_vector(cl_fix_width(result_fmt)-1 downto 0);
    begin
        temp_v := cl_fix_add(a, a_fmt, b, b_fmt, TempFmt_c, Trunc_s, None_s);
        result_v := cl_fix_shift(temp_v, TempFmt_c, -1, result_fmt, round, saturate);
        return result_v;
    end;
    
    function cl_fix_mean_angle(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        precise     : boolean;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        constant TempFmt_c  : FixFormat_t :=
            (
                Signed      => a_fmt.Signed or b_fmt.Signed,
                IntBits     => max(a_fmt.IntBits, b_fmt.IntBits) + 1,
                FracBits    => max(a_fmt.FracBits, b_fmt.FracBits)
            );
        constant TempWidth_c: positive := cl_fix_width(TempFmt_c);
        variable a_v        : std_logic_vector(cl_fix_width(a_fmt)-1 downto 0);
        variable b_v        : std_logic_vector(cl_fix_width(b_fmt)-1 downto 0);
        variable temp_v     : std_logic_vector(TempWidth_c-1 downto 0);
        variable result_v   : std_logic_vector(cl_fix_width(result_fmt)-1 downto 0);
        variable differentSigns_v   : boolean;
    begin
        assert a_fmt.Signed = b_fmt.Signed and a_fmt.IntBits = b_fmt.IntBits
            report "cl_fix_mean_angle : Signed and IntBits of 'a' and 'b' must be identical."
            severity failure;
        assert cl_fix_width(a_fmt) >= 2 and cl_fix_width(b_fmt) >= 2
            report "cl_fix_mean_angle : The widths of 'a' and 'b' must be at least 2 bits each."
            severity failure;

        a_v := a;
        b_v := b;
        differentSigns_v := a_v(a_v'high) /= b_v(b_v'high);
        if differentSigns_v and
                a_v(a_v'high) /= a_v(a_v'high-1) and b_v(b_v'high) /= b_v(b_v'high-1) then
            a_v(a_v'high) := not a_v(a_v'high);
        end if;
        temp_v := cl_fix_add(a, a_fmt, b, b_fmt, TempFmt_c, Trunc_s, None_s);
        if precise and differentSigns_v and a_v(a_v'high-1) = b_v(b_v'high-1) and
                temp_v(temp_v'high-2) = a_v(a_v'high-1) then
            temp_v(temp_v'high) := not temp_v(temp_v'high);
        end if;
        result_v := cl_fix_resize(temp_v, TempFmt_c, result_fmt, round, saturate);
        return result_v;
    end;
    
    function cl_fix_shift(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        shift       : integer;
        result_fmt  : FixFormat_t;
        round       : FixRound_t    := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        constant TempFmt_c  : FixFormat_t :=
            (
                Signed      => result_fmt.Signed,
                IntBits     => result_fmt.IntBits - shift,
                FracBits    => result_fmt.FracBits + shift
            );
    begin
        return cl_fix_resize(a, a_fmt, TempFmt_c, round, saturate);
    end;
    
    function cl_fix_mult(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t    := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        constant TempSigned_c : boolean := a_fmt.Signed or b_fmt.Signed;
        constant TempFmt_c  : FixFormat_t :=
            (
                Signed      => TempSigned_c,
                IntBits     => a_fmt.IntBits + b_fmt.IntBits + toInteger(TempSigned_c),
                FracBits    => a_fmt.FracBits + b_fmt.FracBits
            );
        variable a_v        : std_logic_vector(a'length-1 downto 0);
        variable b_v        : std_logic_vector(b'length-1 downto 0);
        variable temp_v     : std_logic_vector(cl_fix_width(TempFmt_c)-1 downto 0);
        variable result_v   : std_logic_vector(cl_fix_width(result_fmt)-1 downto 0);
    begin
        a_v := a;
        b_v := b;
        if a_fmt.Signed then
            if b_fmt.Signed then
                temp_v := std_logic_vector(signed(a_v) * signed(b_v));
            else
                temp_v := std_logic_vector(signed(a_v) * ("0" & signed(b_v)));
            end if;
        else
            if b_fmt.Signed then
                temp_v := std_logic_vector(("0" & signed(a_v)) * signed(b_v));
            else
                temp_v := std_logic_vector(unsigned(a_v) * unsigned(b_v));
            end if;
        end if;
        result_v := cl_fix_resize(temp_v, TempFmt_c, result_fmt, round, saturate);
        return result_v;
    end;
    
    function cl_fix_compare(
        comparison  : string;
        a           : std_logic_vector;
        aFmt        : FixFormat_t;
        b           : std_logic_vector;
        bFmt        : FixFormat_t
    ) return boolean is
        constant FullFmt_c  : FixFormat_t   := (aFmt.Signed or bFmt.Signed, max(aFmt.IntBits, bFmt.IntBits), max(aFmt.FracBits, bFmt.FracBits));
        variable AFull_v    : std_logic_vector(cl_fix_width(FullFmt_c)-1 downto 0);
        variable BFull_v    : std_logic_vector(cl_fix_width(FullFmt_c)-1 downto 0);
    begin
        -- Convert to same type
        AFull_v := cl_fix_resize(a, aFmt, FullFmt_c);
        BFull_v := cl_fix_resize(b, bFmt, FullFmt_c);
        -- Convert to unsigned representation with offset
        if FullFmt_c.Signed then
            AFull_v(AFull_v'high) := not AFull_v(AFull_v'high);
            BFull_v(BFull_v'high) := not BFull_v(BFull_v'high);
        end if;
        -- Copare
        if    comparison = "a=b"  then return unsigned(AFull_v) = unsigned(BFull_v);
        elsif comparison = "a<b"  then return unsigned(AFull_v) < unsigned(BFull_v);
        elsif comparison = "a>b"  then return unsigned(AFull_v) > unsigned(BFull_v);
        elsif comparison = "a<=b" then return unsigned(AFull_v) <= unsigned(BFull_v);
        elsif comparison = "a>=b" then return unsigned(AFull_v) >= unsigned(BFull_v);
        elsif comparison = "a!=b" then return unsigned(AFull_v) /= unsigned(BFull_v);
        else
            report "###ERROR###: cl_fix_compare illegal comparison type [" & comparison & "]" severity error;
            return false;
        end if;
    end function;
end;
