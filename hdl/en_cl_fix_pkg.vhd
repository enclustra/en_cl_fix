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
    use ieee.numeric_std.all;
    use ieee.math_real.all;

library work;
    use work.en_cl_fix_private_pkg.all;

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
    
    constant NullFixFormat_c    : FixFormat_t := (0, 0, -1);
    
    type FixFormatArray_t is array(natural range <>) of FixFormat_t;
    
    type FixRound_t is
    (
        Trunc_s,        -- Truncation (no rounding).
        NonSymPos_s,    -- Non-symmetric positive (half-up).
        NonSymNeg_s,    -- Non-symmetric negative (half-down).
        SymInf_s,       -- Symmetric towards +/- infinity.
        SymZero_s,      -- Symmetric towards 0.
        ConvEven_s,     -- Convergent towards even number.
        ConvOdd_s       -- Convergent towards odd number.
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
    
    function cl_fix_round_fmt(a_fmt : FixFormat_t; r_frac_bits : integer; rnd : FixRound_t) return FixFormat_t;
    
    function choose(condition : boolean; a_fmt, b_fmt : FixFormat_t) return FixFormat_t;
    
    -----------------------------------------------------------------------------------------------
    -- String Conversions
    -----------------------------------------------------------------------------------------------
    function to_string(a : std_logic_vector; a_fmt : FixFormat_t) return string;
    
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
    
    function cl_fix_to_integer(a : std_logic_vector; aFmt : FixFormat_t) return integer;
    
    function cl_fix_from_integer(a : integer; aFmt : FixFormat_t) return std_logic_vector;

    -----------------------------------------------------------------------------------------------
    -- Rounding and Saturation
    -----------------------------------------------------------------------------------------------
    function cl_fix_round(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        fmt_check   : boolean := true
    ) return std_logic_vector;
    
    function cl_fix_saturate(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_resize(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_in_range(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s
    ) return boolean;
    
    -----------------------------------------------------------------------------------------------
    -- Math Functions
    -----------------------------------------------------------------------------------------------
    function cl_fix_abs(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t := NullFixFormat_c;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_neg(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t := NullFixFormat_c;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_add(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t := NullFixFormat_c;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_sub(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t := NullFixFormat_c;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_addsub(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        add         : std_logic;
        result_fmt  : FixFormat_t := NullFixFormat_c;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_mult(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t := NullFixFormat_c;
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
    
    function cl_fix_compare(
        comparison  : string;
        a           : std_logic_vector;
        aFmt        : FixFormat_t;
        b           : std_logic_vector;
        bFmt        : FixFormat_t
    ) return boolean;
    
    function cl_fix_sign(a : std_logic_vector; aFmt : FixFormat_t) return std_logic;
    
end package;

---------------------------------------------------------------------------------------------------
-- Package Body
---------------------------------------------------------------------------------------------------
package body en_cl_fix_pkg is
    
    -----------------------------------------------------------------------------------------------
    -- Internal Functions
    -----------------------------------------------------------------------------------------------
    function max_real(fmt : FixFormat_t) return real is
    begin
        return 2.0**fmt.I - 2.0**(-fmt.F);
    end function;
    
    function min_real(fmt : FixFormat_t) return real is
    begin
        if fmt.S = 1 then
            return -2.0**fmt.I;
        else
            return 0.0;
        end if;
    end function;
    
    function get_half(aFmt, rFmt : FixFormat_t) return unsigned is
        constant tie_c  : natural := aFmt.F - rFmt.F - 1;
        variable v      : unsigned(cl_fix_width(aFmt)-1 downto 0) := (others => '0');
    begin
        -- Set the "tie" bit (i.e. half the LSB weight of rFmt)
        v(tie_c) := '1';
        return v;
    end function;
    
    function get_unit_bit(a : std_logic_vector; aFmt, rFmt : FixFormat_t) return std_logic is
        -- Force downto 0
        constant a_c    : std_logic_vector(a'length-1 downto 0) := a;
        constant unit_c : natural := aFmt.F - rFmt.F;
    begin
        if unit_c >= cl_fix_width(aFmt) then
            -- Implicit MSB extension
            return cl_fix_sign(a_c, aFmt);
        else
            -- Normal behavior: get the explicit "unit" bit (i.e. the LSB weight of rFmt)
            return a_c(unit_c);
        end if;
    end function;
    
    function resize_sensible(a : signed; n : natural) return signed is
        -- Force downto 0
        constant a_c    : signed(a'length-1 downto 0) := a;
        variable v      : signed(n-1 downto 0);
    begin
        if n >= a'length then
            -- Sign extension: Use the standard VHDL function.
            v := resize(a_c, n);
        else
            -- Truncation: Just do plain truncation.
            -- This is usually more sensible than numeric_std.resize, which preserves the sign bit.
            v := a_c(n-1 downto 0);
        end if;
        return v;
    end function;
    
    function convert(a : std_logic_vector; aFmt, rFmt : FixFormat_t) return std_logic_vector is
        -- Force downto 0
        constant a_c    : std_logic_vector(a'length-1 downto 0) := a;
        
        -- This function converts from aFmt to rFmt without any rounding or saturation:
        --     - It does *not* support rFmt.F < aFmt.F (offset_c is type natural). To reduce frac
        --       bits, always use cl_fix_round (Trunc_s rounding mode can be used to truncate).
        --     - It does support (rFmt.S+rFmt.I) < (aFmt.S+aFmt.I) *without* saturation. In other
        --       words, this implements cl_fix_saturate, with None_s saturation mode.
        constant r_width_c  : natural := cl_fix_width(rFmt);
        constant offset_c   : natural := rFmt.F - aFmt.F;
        variable result_v   : std_logic_vector(r_width_c-1 downto 0) := (others => '0');
    begin
        -- Write the input value into result_v with correct binary point alignment.
        -- We sign extend into any extra int bits (and offset_c LSBs are defaulted to '0').
        if aFmt.S = 0 then
            result_v(r_width_c-1 downto offset_c) := std_logic_vector(resize(unsigned(a_c), r_width_c - offset_c));
        else
            result_v(r_width_c-1 downto offset_c) := std_logic_vector(resize_sensible(signed(a_c), r_width_c - offset_c));
        end if;
        
        return result_v;
    end function;
    
    function union(aFmt, bFmt : FixFormat_t) return FixFormat_t is
    begin
        return (
            S => maximum(aFmt.S, bFmt.S),
            I => maximum(aFmt.I, bFmt.I),
            F => maximum(aFmt.F, bFmt.F)
        );
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
        -- If aFmt.I >= bFmt.I, then we get 1 bit of growth if:
        --           -2**-aFmt.F + 2**bFmt.I - 2**-bFmt.F >= 0
        -- If bFmt.I >= aFmt.I, then we get 1 bit of growth if:
        --           -2**-bFmt.F + 2**aFmt.I - 2**-aFmt.F >= 0
        -- Note that the aFmt.I == bFmt.I case is covered by either condition.
        -- We define maxFmt as the format with most int bits, and minFmt as the other. (As noted
        -- above, it doesn't matter which we treat as max/min when aFmt.I == bFmt.I). This gives a
        -- general expression for when bit-growth happens:
        --           -2**-maxFmt.F + 2**minFmt.I - 2**-minFmt.F >= 0
        -- If we rearrange the expression into pure integer arithmetic, we get:
        --      2**(minFmt.F+minFmt.I+maxFmt.F) >= 2**minFmt.F + 2**maxFmt.F
        -- Equality is only possible if the RHS is a power of 2, so we can remove the 2**n by
        -- splitting this into two simple cases:
        --      (1) If minFmt.F == maxFmt.F = F:
        --          F+minFmt.I+F >= F+1
        --          minFmt.I+F >= 1
        --          minFmt.I+F > 0
        --      (2) Else:
        --          minFmt.F+minFmt.I+maxFmt.F > max(minFmt.F, maxFmt.F)
        --          minFmt.I+maxFmt.F > max(minFmt.F, maxFmt.F) - minFmt.F
        -- Clearly, the expression for (2) also covers (1). We finally simplify the expression by
        -- noting that in general x+y-max(x,y) = min(x,y):
        --          minFmt.I + min(minFmt.F, maxFmt.F) > 0
        --          min(aFmt.I, bFmt.I) + min(aFmt.F, bFmt.F) > 0
        -- There is probably a more direct way to derive this simple expression.
        constant rmax_growth_c  : natural := choose(minimum(a_fmt.I, b_fmt.I) + minimum(a_fmt.F, b_fmt.F) > 0, 1, 0);
        
        -- rmin = amin+bmin
        --     If aFmt.S = 0 and bFmt.S = 0: 0 + 0
        --     If aFmt.S = 0 and bFmt.S = 1: 0 + -2**bFmt.I
        --     If aFmt.S = 1 and bFmt.S = 0: -2**aFmt.I + 0
        --     If aFmt.S = 1 and bFmt.S = 1: -2**aFmt.I + -2**bFmt.I
        constant rmin_growth_c  : natural := choose(a_fmt.S = 1 and b_fmt.S = 1, 1, 0);
    begin
        return (
            maximum(a_fmt.S, b_fmt.S),
            maximum(a_fmt.I, b_fmt.I) + maximum(rmin_growth_c, rmax_growth_c),
            maximum(a_fmt.F, b_fmt.F)
        );
    end;
    
    function cl_fix_sub_fmt(a_fmt : FixFormat_t; b_fmt : FixFormat_t) return FixFormat_t is
        variable growth_v       : natural range 0 to 1;
        variable rmaxI_v        : integer;
        variable rminI_v        : integer;
        variable S_v            : natural range 0 to 1;
        variable I_v            : integer;
    begin
        -- We must consider both extremes:
        
        -- rmax = amax-bmin
        --     If bFmt.S = 0: rmax = (2**aFmt.I - 2**-aFmt.F) - 0
        --     If bFmt.S = 1: rmax = (2**aFmt.I - 2**-aFmt.F) + 2**bFmt.I
        -- If bFmt.S = 0, then rmaxFmt = aFmt.
        -- If bFmt.S = 1 and aFmt.I >= bFmt.I, then we get 1 bit of growth if:
        --                -2**-aFmt.F + 2**bFmt.I >= 0
        --                              2**bFmt.I >= 2**-aFmt.F
        -- If bFmt.S = 1 and bFmt.I >= aFmt.I, then we get 1 bit of growth if:
        --                -2**-aFmt.F + 2**aFmt.I >= 0
        --                              2**aFmt.I >= 2**-aFmt.F
        if b_fmt.S = 0 then
            rmaxI_v := a_fmt.I;
        else
            growth_v := choose(minimum(a_fmt.I, b_fmt.I) >= -a_fmt.F, b_fmt.S, 0);
            rmaxI_v := maximum(a_fmt.I, b_fmt.I) + growth_v;
        end if;
        
        -- rmin = amin-bmax
        --     If aFmt.S = 0: rmin = 0 - (2**bFmt.I - 2**-bFmt.F)
        --     If aFmt.S = 1: rmin = -2**aFmt.I - (2**bFmt.I - 2**-bFmt.F)
        -- If aFmt.S = 0 and bFmt.I = -bFmt.F, then rFmt.S=0 with no requirement on rFmt.I.
        -- If aFmt.S = 0 and bFmt.I = -bFmt.F+1, then we have a special case (power of 2) such that
        -- rmin = -2**-bFmt.F, so rFmt.S=1 and rFmt.I = -bFmt.F.
        -- If aFmt.S = 0 and (all other cases), then rFmt.S=1 and rFmt.I=bFmt.I.
        -- If aFmt.S = 1 and aFmt.I >= bFmt.I, then we get 1 bit of growth if:
        --                       2**bFmt.I - 2**-bFmt.F > 0
        -- If aFmt.S = 1 and bFmt.I >= aFmt.I, then we get 1 bit of growth if:
        --                       2**aFmt.I - 2**-bFmt.F > 0
        if a_fmt.S = 0 then
            if cl_fix_width(b_fmt) = 1 and b_fmt.S = 1 then
                -- Special case: a is unsigned and b is 1-bit signed:
                S_v := 0;
                I_v := rmaxI_v;
            elsif b_fmt.I = -b_fmt.F+1 then
                -- Special case: a is unsigned and rmin is a power of 2
                S_v := 1;
                I_v := maximum(rmaxI_v, -b_fmt.F);
            else
                -- Normal case for unsigned a
                S_v := 1;
                I_v := maximum(rmaxI_v, b_fmt.I);
            end if;
        else
            -- Signed a
            S_v := 1;
            growth_v := choose(minimum(a_fmt.I, b_fmt.I) > -b_fmt.F, a_fmt.S, 0);
            rminI_v := maximum(a_fmt.I, b_fmt.I) + growth_v;
            I_v := maximum(rmaxI_v, rminI_v);
        end if;
        
        return (S_v, I_v, maximum(a_fmt.F, b_fmt.F));
    end;
    
    function cl_fix_addsub_fmt(a_fmt : FixFormat_t; b_fmt : FixFormat_t) return FixFormat_t is
        constant add_fmt_c  : FixFormat_t := cl_fix_add_fmt(a_fmt, b_fmt);
        constant sub_fmt_c  : FixFormat_t := cl_fix_sub_fmt(a_fmt, b_fmt);
    begin
        -- Take the max over add and sub formats.
        return union(add_fmt_c, sub_fmt_c);
    end;
    
    function cl_fix_mult_fmt(a_fmt : FixFormat_t; b_fmt : FixFormat_t) return FixFormat_t is
        constant a_neg_fmt_c    : FixFormat_t := cl_fix_neg_fmt(a_fmt);
        constant b_neg_fmt_c    : FixFormat_t := cl_fix_neg_fmt(b_fmt);
        variable rmaxI_v        : integer;
        variable S_v            : natural range 0 to 1;
        variable I_v            : integer;
    begin
        -- We must consider both extremes:
        
        -- rmax:
        -- If aFmt.S == 1 and bFmt.S == 1, then:
        --     rmax = amin * bmin
        --          = -2**aFmt.I * -2**bFmt.I = 2**(aFmt.I + bFmt.I)
        --          ==> aFmt.I + bFmt.I + 1 int bits.
        -- Else:
        --     rmax = amax * bmax
        --          = (2**aFmt.I - 2**-aFmt.F) * (2**bFmt.I - 2**-bFmt.F)
        --          = 2**(aFmt.I + bFmt.I) - 2**(aFmt.I - bFmt.F) - 2**(bFmt.I - aFmt.F) + 2**(-aFmt.F - bFmt.F)
        --     This will typically need aFmt.I + bFmt.I int bits, but -1 bit if:
        --          2**(aFmt.I + bFmt.I) - 2**(aFmt.I - bFmt.F) - 2**(bFmt.I - aFmt.F) + 2**(-aFmt.F - bFmt.F) < 2**(aFmt.I + bFmt.I - 1)
        --     If we define x=aFmt.I+aFmt.F and y=bFmt.I+bFmt.F, then we can rearrange this to:
        --          2**(x+y-1) + 1 < 2**x + 2**y
        --     Further rearrangement leads to:
        --          (2**x - 2)(2**y - 2) < 2
        --     Note that x>=0 and y>=0 because we do not support I+F<0. So, it is fairly easy to see
        --     the inequality is true iff x<=1 or y<=1 (and this is trivial to confirm numerically).
        if a_fmt.S = 1 and b_fmt.S = 1 then
            rmaxI_v := a_fmt.I + b_fmt.I + 1;
        elsif a_fmt.I+a_fmt.F <= 1 or b_fmt.I+b_fmt.F <= 1 then
            rmaxI_v := a_fmt.I + b_fmt.I - 1;
        else
            rmaxI_v := a_fmt.I + b_fmt.I;
        end if;
        
        -- rmin:
        -- If aFmt.S == 0 and bFmt.S == 0, then:
        --     rmin = amin * bmin = 0
        --     ==> No requirement.
        -- If aFmt.S == 0 and bFmt.S == 1, then:
        --     rmin = amax * bmin = (2**aFmt.I - 2**-aFmt.F) * -2**bFmt.I
        --                        = -amax * 2**bFmt.I
        --     ==> Same as FixFormat.ForNeg(aFmt).I + bFmt.I
        -- If aFmt.S == 1 and bFmt.S == 0, then:
        --     rmin = amin * bmax
        --     ==> Same as FixFormat.ForNeg(bFmt).I + aFmt.I
        -- If aFmt.S == 1 and bFmt.S == 1, then:
        --     rmin = min(amax * bmin, amin * bmax)
        --     ==> Never exceeds rmaxI ==> Ignore.
        
        -- The requirement can exceed rmaxI only if aFmt.S != bFmt.S and we don't run into the same
        -- special case as FixFormat.ForNeg() (i.e. the unsigned value being 1-bit).
        if a_fmt.S = 0 and b_fmt.S = 1 then
            I_v := maximum(rmaxI_v, a_neg_fmt_c.I + b_fmt.I);
        elsif a_fmt.S = 1 and b_fmt.S = 0 then
            I_v := maximum(rmaxI_v, a_fmt.I + b_neg_fmt_c.I);
        else
            I_v := rmaxI_v;
        end if;
        
        -- Sign bit
        if cl_fix_width(a_fmt) = 1 and a_fmt.S = 1 and cl_fix_width(b_fmt) = 1 and b_fmt.S = 1 then
            -- Special case: 1-bit signed * 1-bit signed is unsigned
            S_v := 0;
        else
            -- Normal: If either input is signed, then output is signed
            S_v := maximum(a_fmt.S, b_fmt.S);
        end if;
        
        return (S_v, I_v, a_fmt.F+b_fmt.F);
    end;
    
    function cl_fix_neg_fmt(a_fmt : FixFormat_t) return FixFormat_t is
    begin
        -- 1-bit unsigned inputs are special (neg is 1-bit signed)
        if a_fmt.S = 0 and cl_fix_width(a_fmt) = 1 then
            return (1, a_fmt.I + a_fmt.S - 1, a_fmt.F);
        end if;
        
        -- Normal case: 1 bit of growth for signed inputs due to the asymmetry of two's complement.
        return (1, a_fmt.I + a_fmt.S, a_fmt.F);
    end;
    
    function cl_fix_abs_fmt(a_fmt : FixFormat_t) return FixFormat_t is
        constant neg_fmt_c  : FixFormat_t := cl_fix_neg_fmt(a_fmt);
    begin
        return union(a_fmt, neg_fmt_c);
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
    
    function cl_fix_round_fmt(a_fmt : FixFormat_t; r_frac_bits : integer; rnd : FixRound_t) return FixFormat_t is
        variable I_v    : integer;
    begin
        if r_frac_bits >= a_fmt.F then
            -- If fractional bits are not being reduced, then nothing happens to int bits.
            I_v := a_fmt.I;
        elsif rnd = Trunc_s then
            -- Crude truncation has no effect on int bits.
            I_v := a_fmt.I;
        else
            -- All other rounding modes can overflow into +1 int bit.
            I_v := a_fmt.I + 1;
        end if;
        
        -- Force result to be at least 1 bit wide
        if a_fmt.S + I_v + r_frac_bits < 1 then
            I_v := -a_fmt.S - r_frac_bits + 1;
        end if;
        
        return (a_fmt.S, I_v, r_frac_bits);
    end;
    
    function choose(condition : boolean; a_fmt, b_fmt : FixFormat_t) return FixFormat_t is
    begin
        if condition then
            return a_fmt;
        end if;
        return b_fmt;
    end function;
    
    function to_string(a : std_logic_vector; a_fmt : FixFormat_t) return string is
        function to_char(x : std_logic) return character is
            constant slv_char_c : string(1 to 9) := ('U', 'X', '0', '1', 'Z', 'W', 'L', 'H', '-');
        begin
            return slv_char_c(1 + std_logic'pos(x));
        end;
        
        -- Force downto 0
        constant a_c            : std_logic_vector(cl_fix_width(a_fmt)-1 downto 0) := a;
        constant all_explicit_c : natural := choose(a_fmt.S+a_fmt.I>=0 and a_fmt.F>=0, 1, 0);
        constant pre_length_c   : natural := choose(a_fmt.S+a_fmt.I<0, 3-(a_fmt.S+a_fmt.I), 0);
        constant post_length_c  : natural := choose(a_fmt.F<0, 3-a_fmt.F, 0);
        variable pre_v          : string(1 to pre_length_c);
        variable main_v         : string(1 to a_c'length+all_explicit_c); -- +1 for binary point.
        variable post_v         : string(1 to post_length_c);
    begin
        if all_explicit_c = 1 then
            -- Print explicit S+I bits
            for i in 1 to a_fmt.S+a_fmt.I loop
                main_v(i) := to_char(a_c(a_c'length-i));
            end loop;
            
            -- Print binary point
            main_v(a_fmt.S+a_fmt.I+1) := '.';
            
            -- Print explicit F bits
            for i in 1 to a_fmt.F loop
                main_v(a_fmt.S+a_fmt.I+1+i) := to_char(a_c(a_fmt.F-i));
            end loop;
        else
            -- Print implicit leading fractional bits (if a_fmt.S+a_fmt.I < 0)
            if pre_length_c > 0 then
                pre_v(1 to 2) := ".(";
                for i in 3 to pre_length_c-1 loop
                    pre_v(i) := to_char(cl_fix_sign(a, a_fmt));
                end loop;
                pre_v(pre_length_c) := ')';
            end if;
            
            -- Print all explicit bits
            for i in 1 to a_c'length loop
                main_v(i) := to_char(a_c(a_c'length-i));
            end loop;
            
            -- Print implicit trailing integer bits (if a_fmt.F < 0)
            if post_length_c > 0 then
                post_v(1) := '(';
                for i in 2 to post_length_c-2 loop
                    post_v(i) := '0';
                end loop;
                post_v(post_length_c-1 to post_length_c) := ").";
            end if;
        end if;
        
        return pre_v & main_v & post_v;
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
            report "cl_fix_format_from_string: Format string is missing '('" severity Failure;
        -- Number of sign bits must be 0 or 1
        if Str(Index_v+1) = '0' then
            Format_v.S := 0;
        elsif Str(Index_v+1) = '1' then
            Format_v.S := 1;
        else
            report "cl_fix_format_from_string: Unsupported number of sign bits: " & Str(Index_v+1) severity Failure;
        end if;
        Index_v := string_find_next_match(Str, ',', Index_v+1);
        assert Index_v > 0
            report "cl_fix_format_from_string: Format string is missing ',' between S and I" severity Failure;
        Format_v.I := string_parse_int(Str, Index_v+1);
        Index_v := string_find_next_match(Str, ',', Index_v+1);
        assert Index_v > 0
            report "cl_fix_format_from_string: Format string is missing ',' between I and F" severity Failure;
        Format_v.F := string_parse_int(Str, Index_v+1);
        Index_v := string_find_next_match(Str, ')', Index_v+1);
        assert Index_v > 0
            report "cl_fix_format_from_string: Format string is missing ')'" severity Failure;
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
        variable ChunkInt_v     : integer;
        variable Result_v       : std_logic_vector(ChunkSize_c*ChunkCount_c-1 downto 0);
    begin
        -- Saturation is mandatory in this function (because wrapping has not been implemented)
        assert saturate = SatWarn_s or saturate = Sat_s
            report "cl_fix_for_real: Saturation mode must be SatWarn_s or Sat_s"
            severity Failure;
            
        -- Saturate
        if a > max_real(result_fmt) then
            ASat_v := max_real(result_fmt);
        elsif a < min_real(result_fmt) then
            ASat_v := min_real(result_fmt);
        else
            ASat_v := a;
        end if;
        
        -- Rescale to appropriate fractional bits, with half-up rounding
        ASat_v := floor(ASat_v * 2.0**result_fmt.F + 0.5);
        
        -- Convert to fixed-point in chunks (required for formats that don't fit into integer)
        for i in 0 to ChunkCount_c-1 loop
            -- Note: Due to a Xilinx Vivado bug, we must explicitly call the math_real mod operator
            ChunkInt_v := integer(ieee.math_real."mod"(ASat_v, 2.0**ChunkSize_c));
            if ChunkInt_v > 0 then
                Chunk_v := std_logic_vector(to_unsigned(ChunkInt_v, ChunkSize_c));
            else
                Chunk_v := std_logic_vector(to_signed(ChunkInt_v, ChunkSize_c));
            end if;
            Result_v((i+1)*ChunkSize_c-1 downto i*ChunkSize_c) := Chunk_v;
            ASat_v := floor(ASat_v/2.0**ChunkSize_c);
        end loop;
        
        return Result_v(cl_fix_width(result_fmt)-1 downto 0);
    end;
    
    function cl_fix_to_real(a : std_logic_vector; a_fmt : FixFormat_t) return real is
        constant ABits_c        : natural := cl_fix_width(a_fmt);
        constant ChunkSize_c    : positive := 30;
        constant ChunkCount_c   : natural := (ABits_c + ChunkSize_c - 1)/ChunkSize_c;
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
    
    function cl_fix_from_integer(a : integer; aFmt : FixFormat_t) return std_logic_vector is
    begin
        if aFmt.S = 1 then
            return std_logic_vector(to_signed(a, cl_fix_width(aFmt)));
        else
            return std_logic_vector(to_unsigned(a, cl_fix_width(aFmt)));
        end if;
    end function;
    
    function cl_fix_to_integer(a : std_logic_vector; aFmt : FixFormat_t) return integer is
        -- Force downto 0
        constant a_c    : std_logic_vector(a'length-1 downto 0) := a;
    begin
        -- Modelsim throws warnings if to_integer() is called on 1-bit signed or any 0-bit input.
        -- We handle these special cases explicitly to avoid the warnings.
        if cl_fix_width(aFmt) = 0 then
            return 0;
        elsif aFmt.S = 1 and cl_fix_width(aFmt) = 1 then
            if a_c(0) = '1' then
                -- Note: -1 in the integer representation is -2**aFmt.I in fixed point.
                return -1;
            else
                return 0;
            end if;
        end if;
        
        -- Normal cases
        if aFmt.S = 1 then
            return to_integer(signed(a_c));
        else
            return to_integer(unsigned(a_c));
        end if;
    end function;
    
    function cl_fix_round(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        fmt_check   : boolean := true
    ) return std_logic_vector is
        -- Force downto 0
        constant a_c            : std_logic_vector(a'length-1 downto 0) := a;
        
        -- The result format takes care of potential integer growth due to the rounding mode.
        -- In the intermediate calculation, we need to +/- up to 2.0**-(result_fmt.F+1) in order to
        -- implement each rounding algorithm (except trivial Trunc_s). To keep life simple, we just
        -- force at least result_fmt.F+1 frac bits (even if this is sometimes one too many). The
        -- synthesis tool is likely to optimize this fine.
        constant mid_fmt_c      : FixFormat_t := (
            result_fmt.S,
            result_fmt.I,
            maximum(result_fmt.F+1, a_fmt.F)
        );
        constant in_offset_c    : natural := mid_fmt_c.F - a_fmt.F;
        constant out_offset_c   : natural := mid_fmt_c.F - result_fmt.F;
        constant half_c         : unsigned(cl_fix_width(mid_fmt_c)-1 downto 0) := get_half(mid_fmt_c, result_fmt);
        constant sign_c         : std_logic := cl_fix_sign(a_c, a_fmt);
        variable unit_v         : std_logic;
        variable mid_v          : unsigned(cl_fix_width(mid_fmt_c)-1 downto 0) := (others => '0');
        variable result_v       : std_logic_vector(cl_fix_width(result_fmt)-1 downto 0);
    begin
        if fmt_check then
            assert result_fmt = cl_fix_round_fmt(a_fmt, result_fmt.F, round)
                report "cl_fix_round: Invalid result format. Use cl_fix_round_fmt()." severity Failure;
        end if;
        
        -- Write the input value into mid_v with correct binary point alignment.
        mid_v := unsigned(convert(a_c, a_fmt, mid_fmt_c));
        
        -- To implement each rounding algorithm, we add an appropriate offset before truncating.
        if result_fmt.F < a_fmt.F then
            
            -- Get the least significant bit in the result format (for convergent rounding)
            unit_v := get_unit_bit(std_logic_vector(mid_v), mid_fmt_c, result_fmt);
            
            case round is
                when Trunc_s =>
                    null;  -- Crude truncation => no offset.
                when NonSymPos_s =>
                    mid_v := mid_v + half_c;
                when NonSymNeg_s =>
                    mid_v := mid_v + (half_c-1);
                when SymInf_s =>
                    mid_v := mid_v + half_c - ("" & sign_c);
                when SymZero_s =>
                    mid_v := mid_v + half_c - ("" & not sign_c);
                when ConvEven_s =>
                    mid_v := mid_v + half_c - ("" & not unit_v);
                when ConvOdd_s =>
                    mid_v := mid_v + half_c - ("" & unit_v);
                when others => report "Unrecognized rounding mode: " & to_string(round) severity Failure;
            end case;
        end if;
        
        -- Truncate (and force downto 0 by assigning to result_v before returning)
        result_v := std_logic_vector(mid_v(cl_fix_width(result_fmt)+out_offset_c-1 downto out_offset_c));
        
        return result_v;
    end;
    
    function cl_fix_saturate(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        variable result_v   : std_logic_vector(cl_fix_width(result_fmt)-1 downto 0);
    begin
        assert result_fmt.F = a_fmt.F report "cl_fix_saturate: Number of frac bits cannot change." severity Failure;
        
        -- Saturation warning
        if saturate = Warn_s or saturate = SatWarn_s then
            assert cl_fix_in_range(a, a_fmt, result_fmt)
                report "cl_fix_saturate : Saturation warning!" severity Warning;
        end if;
        
        -- Write the input value into result_v with correct binary point alignment.
        result_v := convert(a, a_fmt, result_fmt);
        
        -- Saturate
        if saturate = Sat_s or saturate = SatWarn_s then
            if cl_fix_compare("<", a, a_fmt, cl_fix_min_value(result_fmt), result_fmt) then
                result_v := cl_fix_min_value(result_fmt);
            elsif cl_fix_compare(">", a, a_fmt, cl_fix_max_value(result_fmt), result_fmt) then
                result_v := cl_fix_max_value(result_fmt);
            end if;
        end if;
        
        return result_v;
    end;
    
    function cl_fix_resize(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t    := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        -- Round
        constant rounded_fmt_c  : FixFormat_t := cl_fix_round_fmt(a_fmt, result_fmt.F, round);
        constant rounded_c      : std_logic_vector := cl_fix_round(a, a_fmt, rounded_fmt_c, round);
    begin
        -- Saturate
        return cl_fix_saturate(rounded_c, rounded_fmt_c, result_fmt, saturate);
    end;
    
    function cl_fix_in_range(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s
    ) return boolean is
        -- Note: If result_fmt.F /= a_fmt.F, then we need to know what rounding algorithm will be
        --       used when reducing the LSBs.
        constant rndFmt_c : FixFormat_t := cl_fix_round_fmt(a_fmt, result_fmt.F, round);
        
        -- Apply rounding
        constant Rounded_c  : std_logic_vector := cl_fix_round(to01(a), a_fmt, rndFmt_c, round);
    begin
        return cl_fix_compare(">=", Rounded_c, rndFmt_c, cl_fix_min_value(result_fmt), result_fmt) and
               cl_fix_compare("<=", Rounded_c, rndFmt_c, cl_fix_max_value(result_fmt), result_fmt);
    end;
    
    function cl_fix_abs(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t := NullFixFormat_c;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        constant mid_fmt_c  : FixFormat_t := cl_fix_abs_fmt(a_fmt);
        constant r_fmt_c    : FixFormat_t := choose(result_fmt = NullFixFormat_c, mid_fmt_c, result_fmt);
        variable mid_v      : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
    begin
        if cl_fix_sign(a, a_fmt) = '1' then
            mid_v := cl_fix_neg(a, a_fmt, mid_fmt_c);
        else
            mid_v := convert(a, a_fmt, mid_fmt_c);
        end if;
        return cl_fix_resize(mid_v, mid_fmt_c, r_fmt_c, round, saturate);
    end;
    
    function cl_fix_neg(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t := NullFixFormat_c;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        constant mid_fmt_c  : FixFormat_t := cl_fix_neg_fmt(a_fmt);
        constant r_fmt_c    : FixFormat_t := choose(result_fmt = NullFixFormat_c, mid_fmt_c, result_fmt);
        variable a_v        : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
        variable mid_v      : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
    begin
        a_v := convert(a, a_fmt, mid_fmt_c);
        mid_v := std_logic_vector(-signed(a_v));
        return cl_fix_resize(mid_v, mid_fmt_c, r_fmt_c, round, saturate);
    end;
    
    function cl_fix_add(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t := NullFixFormat_c;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        constant mid_fmt_c  : FixFormat_t := cl_fix_add_fmt(a_fmt, b_fmt);
        constant r_fmt_c    : FixFormat_t := choose(result_fmt = NullFixFormat_c, mid_fmt_c, result_fmt);
        variable a_v        : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
        variable b_v        : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
        variable mid_v      : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
    begin
        a_v := convert(a, a_fmt, mid_fmt_c);
        b_v := convert(b, b_fmt, mid_fmt_c);
        -- Signed/unsigned addition/subtraction are identical when using two's complement.
        -- However, a long-standing Vivado bug causes incorrect post-synthesis behavior in DSP
        -- slices (pre-add or post-add) if numeric_std.unsigned is used. There are no known issues
        -- for numeric_std.signed, so we always use that.
        mid_v := std_logic_vector(signed(a_v) + signed(b_v));
        return cl_fix_resize(mid_v, mid_fmt_c, r_fmt_c, round, saturate);
    end;
    
    function cl_fix_sub(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t := NullFixFormat_c;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        constant mid_fmt_c  : FixFormat_t := cl_fix_sub_fmt(a_fmt, b_fmt);
        constant r_fmt_c    : FixFormat_t := choose(result_fmt = NullFixFormat_c, mid_fmt_c, result_fmt);
        variable a_v        : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
        variable b_v        : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
        variable mid_v      : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
    begin
        a_v := convert(a, a_fmt, mid_fmt_c);
        b_v := convert(b, b_fmt, mid_fmt_c);
        -- Signed/unsigned addition/subtraction are identical when using two's complement.
        -- However, a long-standing Vivado bug causes incorrect post-synthesis behavior in DSP
        -- slices (pre-add or post-add) if numeric_std.unsigned is used. There are no known issues
        -- for numeric_std.signed, so we always use that.
        mid_v := std_logic_vector(signed(a_v) - signed(b_v));
        return cl_fix_resize(mid_v, mid_fmt_c, r_fmt_c, round, saturate);
    end;
    
    function cl_fix_addsub(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        add         : std_logic;
        result_fmt  : FixFormat_t := NullFixFormat_c;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
    begin
        if to01(add) = '1' then
            return cl_fix_add(a, a_fmt, b, b_fmt, result_fmt, round, saturate);
        end if;
        return cl_fix_sub(a, a_fmt, b, b_fmt, result_fmt, round, saturate);
    end;
    
    function cl_fix_mult(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t := NullFixFormat_c;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        -- Force downto 0
        constant a_c            : std_logic_vector(a'length-1 downto 0) := a;
        constant b_c            : std_logic_vector(b'length-1 downto 0) := b;
        
        -- VHDL doesn't define a * operator for mixed signed*unsigned or unsigned*signed.
        -- Just inside cl_fix_mult, it is safe to define them for local use.
        function "*"(x : signed; y : unsigned) return signed is
        begin
            return x * ('0' & signed(y));
        end function;
        
        function "*"(x : unsigned; y : signed) return signed is
        begin
            return y * x;
        end function;
        
        constant mid_fmt_c      : FixFormat_t := cl_fix_mult_fmt(a_fmt, b_fmt);
        constant r_fmt_c        : FixFormat_t := choose(result_fmt = NullFixFormat_c, mid_fmt_c, result_fmt);
        constant mid_width_c    : positive := cl_fix_width(mid_fmt_c);
        variable mid_v          : std_logic_vector(mid_width_c-1 downto 0);
    begin
        if a_fmt.S = 0 and b_fmt.S = 0 then
            mid_v := std_logic_vector(resize(unsigned(a_c) * unsigned(b_c), mid_width_c));
        elsif a_fmt.S = 0 and b_fmt.S = 1 then
            mid_v := std_logic_vector(resize_sensible(unsigned(a_c) * signed(b_c), mid_width_c));
        elsif a_fmt.S = 1 and b_fmt.S = 0 then
            mid_v := std_logic_vector(resize_sensible(signed(a_c) * unsigned(b_c), mid_width_c));
        else
            mid_v := std_logic_vector(resize_sensible(signed(a_c) * signed(b_c), mid_width_c));
        end if;
        
        return cl_fix_resize(mid_v, mid_fmt_c, r_fmt_c, round, saturate);
    end;
    
    function cl_fix_shift(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        shift       : integer;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
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
    
    function cl_fix_compare(
        comparison  : string;
        a           : std_logic_vector;
        aFmt        : FixFormat_t;
        b           : std_logic_vector;
        bFmt        : FixFormat_t
    ) return boolean is
        constant mid_fmt_c  : FixFormat_t := union(aFmt, bFmt);
        variable a_v        : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
        variable b_v        : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
    begin
        -- Convert to same type
        a_v := convert(a, aFmt, mid_fmt_c);
        b_v := convert(b, bFmt, mid_fmt_c);
        
        -- Compare
        if mid_fmt_c.S = 1 then
            if    comparison = "="  then return signed(a_v) =  signed(b_v);
            elsif comparison = "!=" then return signed(a_v) /= signed(b_v);
            elsif comparison = "<"  then return signed(a_v) <  signed(b_v);
            elsif comparison = ">"  then return signed(a_v) >  signed(b_v);
            elsif comparison = "<=" then return signed(a_v) <= signed(b_v);
            elsif comparison = ">=" then return signed(a_v) >= signed(b_v);
            else
                report "cl_fix_compare: Unrecognized comparison type: " & comparison severity Failure;
                return false;
            end if;
        else
            if    comparison = "="  then return unsigned(a_v) =  unsigned(b_v);
            elsif comparison = "!=" then return unsigned(a_v) /= unsigned(b_v);
            elsif comparison = "<"  then return unsigned(a_v) <  unsigned(b_v);
            elsif comparison = ">"  then return unsigned(a_v) >  unsigned(b_v);
            elsif comparison = "<=" then return unsigned(a_v) <= unsigned(b_v);
            elsif comparison = ">=" then return unsigned(a_v) >= unsigned(b_v);
            else
                report "cl_fix_compare: Unrecognized comparison type: " & comparison severity Failure;
                return false;
            end if;
        end if;
    end function;
    
    function cl_fix_sign(a : std_logic_vector; aFmt : FixFormat_t) return std_logic is
        -- Force downto 0
        constant a_c    : std_logic_vector(a'length-1 downto 0) := a;
    begin
        if aFmt.S = 0 or cl_fix_width(aFmt) = 0 then
            return '0';
        end if;
        return a_c(a_c'high);
    end function;
end;
