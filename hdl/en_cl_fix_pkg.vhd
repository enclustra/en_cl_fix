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

---------------------------------------------------------------------------------------------------
-- Package Header
---------------------------------------------------------------------------------------------------

package en_cl_fix_pkg is

    -----------------------------------------------------------------------------------------------
    -- Types
    -----------------------------------------------------------------------------------------------
    
    type FixFormat_t is record
        S   : natural range 0 to 1;  -- Sign bit.
        I   : integer;               -- Integer bits.
        F   : integer;               -- Fractional bits.
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
    
    function cl_fix_width(fmt : FixFormat_t) return natural;
    
    function cl_fix_max_value(fmt : FixFormat_t) return std_logic_vector;
    
    function cl_fix_min_value(fmt : FixFormat_t) return std_logic_vector;
    
    function cl_fix_add_fmt(a_fmt : FixFormat_t; b_fmt : FixFormat_t) return FixFormat_t;
    
    function cl_fix_sub_fmt(a_fmt : FixFormat_t; b_fmt : FixFormat_t) return FixFormat_t;
    
    function cl_fix_addsub_fmt(a_fmt : FixFormat_t; b_fmt : FixFormat_t) return FixFormat_t;
    
    function cl_fix_mult_fmt(a_fmt : FixFormat_t; b_fmt : FixFormat_t) return FixFormat_t;
    
    function cl_fix_neg_fmt(a_fmt : FixFormat_t) return FixFormat_t;
    
    function cl_fix_abs_fmt(a_fmt : FixFormat_t) return FixFormat_t;
    
    function cl_fix_shift_fmt(a_fmt : FixFormat_t; min_shift : integer; max_shift : integer) return FixFormat_t;
    
    function cl_fix_shift_fmt(a_fmt : FixFormat_t; shift : integer) return FixFormat_t;
    
    -----------------------------------------------------------------------------------------------
    -- String Conversions
    -----------------------------------------------------------------------------------------------
    
    function to_string(fmt : FixFormat_t) return string;
    
    function to_string(rnd : FixRound_t) return string;
    
    function to_string(sat : FixSaturate_t) return string;
    
    function cl_fix_format_from_string(Str : string) return FixFormat_t;
    
    function cl_fix_round_from_string(Str : string) return FixRound_t;
    
    function cl_fix_saturate_from_string(Str : string) return FixSaturate_t;

    -----------------------------------------------------------------------------------------------
    -- Type Conversions
    -----------------------------------------------------------------------------------------------
    
    function cl_fix_from_real(a : real; result_fmt : FixFormat_t; saturate : FixSaturate_t := SatWarn_s) return std_logic_vector;
    
    function cl_fix_to_real(a : std_logic_vector; a_fmt : FixFormat_t) return real;
    
    function cl_fix_get_bits_as_int(a : std_logic_vector; aFmt : FixFormat_t) return integer;
    
    function cl_fix_from_bits_as_int(a : integer; aFmt : FixFormat_t) return std_logic_vector;

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
    
    function cl_fix_neg(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
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
    -- Internally used functions
    -----------------------------------------------------------------------------------------------
    
    function choose(condition : boolean; if_true : integer; if_false : integer) return integer is
    begin
        if condition then
            return if_true;
        end if;
        return if_false;
    end function;
    
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
    
    function max_real(fmt : FixFormat_t) return real is
    begin
        return 2.0**fmt.I - 2.0**(-fmt.F);
    end function;
    
    function min_real(fmt : FixFormat_t)return real is
    begin
        if fmt.S = 1 then
            return -2.0**fmt.I;
        else
            return 0.0;
        end if;
    end function;
    
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
    
    -----------------------------------------------------------------------------------------------
    -- Public Functions
    -----------------------------------------------------------------------------------------------
    
    function cl_fix_width(fmt : FixFormat_t) return natural is
    begin
        return fmt.S + fmt.I + fmt.F;
    end;
    
    function cl_fix_max_value(fmt : FixFormat_t) return std_logic_vector is
        variable result_v : std_logic_vector(cl_fix_width(fmt)-1 downto 0);
    begin
        result_v := (others => '1');
        if fmt.S = 1 then
            result_v(result_v'high) := '0';
        end if;
        return result_v;
    end;
    
    function cl_fix_min_value(fmt : FixFormat_t) return std_logic_vector is
        variable result_v : std_logic_vector(cl_fix_width(fmt)-1 downto 0);
    begin
        if fmt.S = 1 then
            result_v := (others => '0');
            result_v(result_v'left) := '1';
        else
            result_v := (others => '0');
        end if;
        return result_v;
    end;
    
    function cl_fix_add_fmt(a_fmt : FixFormat_t; b_fmt : FixFormat_t) return FixFormat_t is
        -- We must consider both extremes:
        
        -- rmax = amax+bmax
        --      = (2**aFmt.I - 2**-aFmt.F) + (2**bFmt.I - 2**-bFmt.F)
        -- If we denote the format with max(aFmt.I, bFmt.I) int bits as "maxFmt" and the other
        -- format as "minFmt", then we get 1 bit of growth if 2**minFmt.I > 2**-maxFmt.F.
        constant rmax_growth_c  : natural := choose((a_fmt.I >= b_fmt.I and b_fmt.I > -a_fmt.F) or (a_fmt.I < b_fmt.I and a_fmt.I > -b_fmt.F), 1, 0);
        
        -- rmin = amin+bmin
        --     If aFmt.S = 0 and bFmt.S = 0: 0 + 0
        --     If aFmt.S = 0 and bFmt.S = 1: 0 + -2**bFmt.I
        --     If aFmt.S = 1 and bFmt.S = 0: -2**aFmt.I + 0
        --     If aFmt.S = 1 and bFmt.S = 1: -2**aFmt.I + -2**bFmt.I
        constant rmin_growth_c  : natural := choose(a_fmt.S = 1 and b_fmt.S = 1, 1, 0);
    begin
        return (
            max(a_fmt.S, b_fmt.S),
            max(a_fmt.I, b_fmt.I) + max(rmin_growth_c, rmax_growth_c),
            max(a_fmt.F, b_fmt.F)
        );
    end;
    
    function cl_fix_sub_fmt(a_fmt : FixFormat_t; b_fmt : FixFormat_t) return FixFormat_t is
        -- We must consider both extremes:
        
        -- rmax = amax-bmin
        --     If bFmt.S = 0: rmax = (2**aFmt.I - 2**-aFmt.F) - 0
        --     If bFmt.S = 1: rmax = (2**aFmt.I - 2**-aFmt.F) + 2**bFmt.I
        -- We get 1 bit of growth in the signed case if -2**-aFmt.F + 2**bFmt.I >= 0.
        constant rmax_growth_c  : natural := choose(b_fmt.I >= -a_fmt.F, b_fmt.S, 0);
        
        -- rmin = amin-bmax
        --     If aFmt.S = 0: rmin = 0 - (2**bFmt.I - 2**-bFmt.F)
        --     If aFmt.S = 1: rmin = -2**aFmt.I - (2**bFmt.I - 2**-bFmt.F)
        -- We get 1 bit of growth in the signed case if -2**aFmt.I + 2**-bFmt.F < 0.
        constant rmin_growth_c  : natural := choose(a_fmt.I > -b_fmt.F, a_fmt.S, 0);
    begin
        return (
            1,
            max(a_fmt.I, b_fmt.I) + max(rmin_growth_c, rmax_growth_c),
            max(a_fmt.F, b_fmt.F)
        );
    end;
    
    function cl_fix_addsub_fmt(a_fmt : FixFormat_t; b_fmt : FixFormat_t) return FixFormat_t is
        constant add_fmt_c  : FixFormat_t := cl_fix_add_fmt(a_fmt, b_fmt);
        constant sub_fmt_c  : FixFormat_t := cl_fix_sub_fmt(a_fmt, b_fmt);
    begin
        return (
            max(add_fmt_c.S, sub_fmt_c.S),
            max(add_fmt_c.I, sub_fmt_c.I),
            max(add_fmt_c.F, sub_fmt_c.F)
        );
    end;
    
    function cl_fix_mult_fmt(a_fmt : FixFormat_t; b_fmt : FixFormat_t) return FixFormat_t is
        -- We get 1 bit of growth for signed*signed (rmax = -2**aFmt.I * -2**bFmt.I).
        constant Growth_c   : natural := min(a_fmt.S, b_fmt.S);
        constant Signed_c   : natural := max(a_fmt.S, b_fmt.S);
    begin
        return (Signed_c, a_fmt.I + b_fmt.I + Growth_c, a_fmt.F + b_fmt.F);
    end;
    
    function cl_fix_neg_fmt(a_fmt : FixFormat_t) return FixFormat_t is
    begin
        return (1, a_fmt.I + a_fmt.S, a_fmt.F);
    end;
    
    function cl_fix_abs_fmt(a_fmt : FixFormat_t) return FixFormat_t is
        constant neg_fmt_c  : FixFormat_t := cl_fix_neg_fmt(a_fmt);
    begin
        return (
            max(a_fmt.S, neg_fmt_c.S),
            max(a_fmt.I, neg_fmt_c.I),
            max(a_fmt.F, neg_fmt_c.F)
        );
    end;
    
    function cl_fix_shift_fmt(a_fmt : FixFormat_t; min_shift : integer; max_shift : integer) return FixFormat_t is
    begin
        assert min_shift <= max_shift report "min_shift must be <= max_shift" severity Failure;
        
        return (a_fmt.S, a_fmt.I + max_shift, a_fmt.F - min_shift);
    end;
    
    function cl_fix_shift_fmt(a_fmt : FixFormat_t; shift : integer) return FixFormat_t is
    begin
        return cl_fix_shift_fmt(a_fmt, shift, shift);
    end;
    
    function to_string(fmt : FixFormat_t) return string is
    begin
        return "(" & natural'image(fmt.S) & "," & integer'image(fmt.I) & "," & integer'image(fmt.F) & ")";
    end;
    
    function to_string(rnd : FixRound_t) return string is
    begin
        -- Some synthesis tools do not support FixRound_t'image(), so we implement explicitly.
        case rnd is
            when Trunc_s     => return "Trunc_s";
            when NonSymPos_s => return "NonSymPos_s";
            when NonSymNeg_s => return "NonSymNeg_s";
            when SymInf_s    => return "SymInf_s";
            when SymZero_s   => return "SymZero_s";
            when ConvEven_s  => return "ConvEven_s";
            when ConvOdd_s   => return "ConvOdd_s";
            when others => report "to_string(FixRound_t) : Unsupported input." severity Failure;
        end case;
        return "";
    end;
    
    function to_string(sat : FixSaturate_t) return string is
    begin
        -- Some synthesis tools do not support FixSaturate_t'image(), so we implement explicitly.
        case sat is
            when None_s    => return "None_s";
            when Warn_s    => return "Warn_s";
            when Sat_s     => return "Sat_s";
            when SatWarn_s => return "SatWarn_s";
            when others => report "to_string(FixSaturate_t) : Unsupported input." severity Failure;
        end case;
        return "";
    end;
    
    function cl_fix_format_from_string(Str : string) return FixFormat_t is
        variable Format_v   : FixFormat_t;
        variable Index_v    : integer;
    begin
        -- Parse Format
        Index_v := Str'low;
        Index_v := string_find_next_match(Str, '(', Index_v);
        assert Index_v > 0
            report "cl_fix_format_from_string: wrong Format, missing '('"
            severity error;
        -- Allow signedness to be specified as an integer
        if Str(Index_v+1) = '0' then
            Format_v.S := 0;
        elsif Str(Index_v+1) = '1' then
            Format_v.S := 1;
        else
            -- Parse signedness as boolean
            Format_v.S := string_parse_int(Str, Index_v+1);
        end if;
        Index_v := string_find_next_match(Str, ',', Index_v+1);
        assert Index_v > 0
            report "cl_fix_format_from_string: wrong Format, missing ',' between IsSigned and I "
            severity error;
        Format_v.I := string_parse_int(Str, Index_v+1);
        Index_v := string_find_next_match(Str, ',', Index_v+1);
        assert Index_v > 0
            report "cl_fix_format_from_string: wrong Format, missing ',' between I and F "
            severity error;
        Format_v.F := string_parse_int(Str, Index_v+1);
        Index_v := string_find_next_match(Str, ')', Index_v+1);
        assert Index_v > 0
            report "cl_fix_format_from_string: wrong Format, missing ')'"
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
    
    function cl_fix_from_real(a : real; result_fmt : FixFormat_t; saturate : FixSaturate_t := SatWarn_s) return std_logic_vector is
        constant ChunkSize_c    : positive := 30;
        constant ChunkCount_c   : positive := (cl_fix_width(result_fmt) + ChunkSize_c - 1)/ChunkSize_c;
        variable ASat_v         : real;
        variable Chunk_v        : std_logic_vector(ChunkSize_c-1 downto 0);
        variable Result_v       : std_logic_vector(ChunkSize_c*ChunkCount_c-1 downto 0);
    begin
        -- Limit
        if a > max_real(result_fmt) then
            ASat_v := max_real(result_fmt);
        elsif a < min_real(result_fmt) then
            ASat_v := min_real(result_fmt);
        else
            ASat_v := a;
        end if;
        
        -- Rescale to appropriate fractional bits
        ASat_v := round(ASat_v * 2.0**(result_fmt.F));
        
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
        if a_fmt.S = 1 and a_v(ABits_c-1) = '1' then
            a_v(ABits_c-1) := '0'; -- Clear sign bit.
            Correction_v := -2.0**(ABits_c-1 - a_fmt.F); -- Remember its weight.
        end if;
        
        -- Resize to an integer number of chunks
        apad_v := resize(unsigned(a_v), ChunkSize_c*ChunkCount_c);
        
        -- Convert to real in chunks
        for i in ChunkCount_c-1 downto 0 loop
            result_v := result_v * 2.0**ChunkSize_c; -- Shift to next chunk.
            Chunk_v := apad_v((i+1)*ChunkSize_c-1 downto i*ChunkSize_c);
            result_v := result_v + real(to_integer(Chunk_v)) * 2.0**(-a_fmt.F);
        end loop;
        
        -- Add sign bit contribution
        result_v := result_v + Correction_v;
        
        return result_v;
    end;
    
    function cl_fix_from_bits_as_int(a : integer; aFmt : FixFormat_t) return std_logic_vector is
    begin
        if aFmt.S = 1 then
            return std_logic_vector(to_signed(a, cl_fix_width(aFmt)));
        else
            return std_logic_vector(to_unsigned(a, cl_fix_width(aFmt)));
        end if;
    end function;
    
    function cl_fix_get_bits_as_int(a : std_logic_vector; aFmt : FixFormat_t) return integer is
    begin
        if aFmt.S = 1 then
            return to_integer(signed(a));
        else
            return to_integer(unsigned(a));
        end if;
    end function;
    
    function cl_fix_resize(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t    := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        constant DropFracBits_c     : integer := a_fmt.F - result_fmt.F;
        constant NeedRound_c        : boolean := round /= Trunc_s and DropFracBits_c > 0;
        -- Rounding addition is performed with an additional integer bit (carry bit)
        constant CarryBit_c         : boolean := NeedRound_c and saturate /= None_s;
        -- It is not clear what this extra bit is for (undocumented)
        constant AddSignBit_c       : boolean := ((a_fmt.S = 0) and (result_fmt.S = 0) and (saturate /= None_s));
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
                S   => max(a_fmt.S, result_fmt.S), -- must stay like this!
                I   => max(a_fmt.I + toInteger(CarryBit_c), result_fmt.I) + toInteger(AddSignBit_c),
                F   => max(a_fmt.F, result_fmt.F)
            );
        constant TempWidth_c        : positive := cl_fix_width(TempFmt_c);
        constant ResultWidth_c      : positive := cl_fix_width(result_fmt);
        constant MoreFracBits_c     : natural := TempFmt_c.F - a_fmt.F;
        constant CutFracBits_c      : natural := TempFmt_c.F - result_fmt.F;
        constant CutIntSignBits_c   : integer := TempWidth_c - (ResultWidth_c+CutFracBits_c);
        
        variable a_v        : std_logic_vector(a'length-1 downto 0);
        variable temp_v     : unsigned(TempWidth_c-1 downto 0);
        variable sign_v     : std_logic;
        variable result_v   : std_logic_vector(ResultWidth_c-1 downto 0);
    begin
        -- TODO: Rounding addition could be less wide when result_fmt.I > a_fmt.IntWidth
        -- TODO: saturate = Warn_s could use no carry bit for synthesis.
        a_v := a;
        temp_v := (others => '0');
        if a_fmt.S = 1 then
            temp_v(temp_v'high downto MoreFracBits_c) := unsigned(resize(signed(a_v), TempWidth_c-MoreFracBits_c));
        else
            temp_v(temp_v'high downto MoreFracBits_c) := resize(unsigned(a_v), TempWidth_c-MoreFracBits_c);
        end if;
        if NeedRound_c then -- rounding required
            if a_fmt.S = 1 then
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
            if result_fmt.S = 1 then -- signed output
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
    
    function cl_fix_in_range(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s
    ) return boolean is
        -- Note: This matches the python implementation
        constant rndFmt_c : FixFormat_t :=
            (
                S   => a_fmt.S,
                I   => a_fmt.I + 1,
                F   => result_fmt.F
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
                S   => a_fmt.S,
                I   => a_fmt.I + a_fmt.S,
                F   => a_fmt.F
            );
        variable a_v        : std_logic_vector(a'length-1 downto 0);
        variable temp_v     : std_logic_vector(cl_fix_width(TempFmt_c)-1 downto 0);
    begin
        a_v := a;
        if a_fmt.S = 1 then
            temp_v := a_v(a_v'high) & a_v;
            if a_v(a_v'high) = '1' then
                temp_v := std_logic_vector(unsigned(not temp_v) + 1);
            end if;
        else
            temp_v := a_v;
        end if;
        return cl_fix_resize(temp_v, TempFmt_c, result_fmt, round, saturate);
    end;
    
    function cl_fix_neg(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        constant mid_fmt_c  : FixFormat_t := cl_fix_neg_fmt(a_fmt);
        variable a_v        : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
        variable mid_v      : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
    begin
        a_v := cl_fix_resize(a, a_fmt, mid_fmt_c);
        mid_v := std_logic_vector(-signed(a_v));
        return cl_fix_resize(mid_v, mid_fmt_c, result_fmt, round, saturate);
    end;
    
    function cl_fix_add(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        constant mid_fmt_c  : FixFormat_t := cl_fix_add_fmt(a_fmt, b_fmt);
        variable a_v        : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
        variable b_v        : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
        variable mid_v      : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
    begin
        a_v := cl_fix_resize(a, a_fmt, mid_fmt_c, Trunc_s, None_s);
        b_v := cl_fix_resize(b, b_fmt, mid_fmt_c, Trunc_s, None_s);
        -- Signed/unsigned addition/subtraction are identical when using two's complement.
        -- However, a long-standing Vivado bug causes incorrect post-synthesis behavior in DSP
        -- slices (pre-add or post-add) if numeric_std.unsigned is used. There are no known issues
        -- for numeric_std.signed, so we always use that.
        mid_v := std_logic_vector(signed(a_v) + signed(b_v));
        return cl_fix_resize(mid_v, mid_fmt_c, result_fmt, round, saturate);
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
        constant mid_fmt_c  : FixFormat_t := cl_fix_sub_fmt(a_fmt, b_fmt);
        variable a_v        : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
        variable b_v        : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
        variable mid_v      : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
    begin
        a_v := cl_fix_resize(a, a_fmt, mid_fmt_c, Trunc_s, None_s);
        b_v := cl_fix_resize(b, b_fmt, mid_fmt_c, Trunc_s, None_s);
        -- Signed/unsigned addition/subtraction are identical when using two's complement.
        -- However, a long-standing Vivado bug causes incorrect post-synthesis behavior in DSP
        -- slices (pre-add or post-add) if numeric_std.unsigned is used. There are no known issues
        -- for numeric_std.signed, so we always use that.
        mid_v := std_logic_vector(signed(a_v) - signed(b_v));
        return cl_fix_resize(mid_v, mid_fmt_c, result_fmt, round, saturate);
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
    
    function cl_fix_shift(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        shift       : integer;
        result_fmt  : FixFormat_t;
        round       : FixRound_t    := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        -- Implicitly shift by resizing to a dummy format, then reinterpreting as result_fmt.
        constant dummy_fmt_c  : FixFormat_t := (result_fmt.S, result_fmt.I - shift, result_fmt.F + shift);
    begin
        -- Note: This function performs a lossless shift (equivalent to *2.0**shift), then resizes
        --       to the output format. The initial shift does NOT truncate any bits.
        -- Note: "shift" direction is left. (So shift<0 shifts right).
        return cl_fix_resize(a, a_fmt, dummy_fmt_c, round, saturate);
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
        -- VHDL doesn't define a * operator for mixed signed*unsigned or unsigned*signed.
        -- Just inside cl_fix_mult, it is safe to define them for local use.
        function "*"(x : signed; y : unsigned) return signed is
            constant Temp_c : signed := x * ('0' & signed(y));
        begin
            -- Drop the redundant MSB
            return Temp_c(Temp_c'high-1 downto Temp_c'low);
        end function;
        
        function "*"(x : unsigned; y : signed) return signed is
        begin
            return y * x;
        end function;
        
        constant mid_fmt_c      : FixFormat_t := cl_fix_mult_fmt(a_fmt, b_fmt);
        variable mid_v          : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
        variable result_v       : std_logic_vector(cl_fix_width(result_fmt)-1 downto 0);
    begin
        if a_fmt.S = 0 and b_fmt.S = 0 then
            mid_v := std_logic_vector(unsigned(a) * unsigned(b));
        elsif a_fmt.S = 0 and b_fmt.S = 1 then
            mid_v := std_logic_vector(unsigned(a) *   signed(b));
        elsif a_fmt.S = 1 and b_fmt.S = 0 then
            mid_v := std_logic_vector(  signed(a) * unsigned(b));
        else
            mid_v := std_logic_vector(  signed(a) *   signed(b));
        end if;
        
        return cl_fix_resize(mid_v, mid_fmt_c, result_fmt, round, saturate);
    end;
    
    function cl_fix_compare(
        comparison  : string;
        a           : std_logic_vector;
        aFmt        : FixFormat_t;
        b           : std_logic_vector;
        bFmt        : FixFormat_t
    ) return boolean is
        constant FullFmt_c  : FixFormat_t   := (max(aFmt.S, bFmt.S), max(aFmt.I, bFmt.I), max(aFmt.F, bFmt.F));
        variable AFull_v    : std_logic_vector(cl_fix_width(FullFmt_c)-1 downto 0);
        variable BFull_v    : std_logic_vector(cl_fix_width(FullFmt_c)-1 downto 0);
    begin
        -- Convert to same type
        AFull_v := cl_fix_resize(a, aFmt, FullFmt_c);
        BFull_v := cl_fix_resize(b, bFmt, FullFmt_c);
        -- Convert to unsigned representation with offset
        if FullFmt_c.S = 1 then
            AFull_v(AFull_v'high) := not AFull_v(AFull_v'high);
            BFull_v(BFull_v'high) := not BFull_v(BFull_v'high);
        end if;
        -- Compare
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
