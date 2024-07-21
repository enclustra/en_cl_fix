---------------------------------------------------------------------------------------------------
-- Copyright (c) 2024 Enclustra GmbH, Switzerland (info@enclustra.com)
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this hardware, software, firmware, and associated documentation files (the
-- "Product"), to deal in the Product without restriction, including without
-- limitation the rights to use, copy, modify, merge, publish, distribute,
-- sublicense, and/or sell copies of the Product, and to permit persons to whom the
-- Product is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Product.
--
-- THE PRODUCT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
-- PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
-- HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
-- OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- PRODUCT OR THE USE OR OTHER DEALINGS IN THE PRODUCT.
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Description:
--
-- This block implements pipelined resizing (rounding and saturation).
--
-- If force_reg_g = true, then pipeline registers are always inserted. This is the best choice when
-- latency needs to be constant, regardless of all other generics. Latency = 2.
--
-- If force_reg_g = false, then pipeline registers are only inserted when required. This is usually
-- the best choice when it is acceptable for latency to change when other generics are changed.
-- Latency = cl_fix_recommended_pipelining(in_fmt_g, out_fmt_g, round_g, saturate_g).
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Libraries
---------------------------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;

library work;
    use work.en_cl_fix_pkg.all;

---------------------------------------------------------------------------------------------------
-- Entity
---------------------------------------------------------------------------------------------------
entity en_cl_fix_resize is
    generic(
        in_fmt_g    : FixFormat_t;
        out_fmt_g   : FixFormat_t;
        round_g     : FixRound_t;
        saturate_g  : FixSaturate_t;
        force_reg_g : boolean          -- See comments above. If unsure, set to true.
    );
    port(
        ------------------------------------------
        -- Clock and Reset
        ------------------------------------------
        clk         : in  std_logic;
        rst         : in  std_logic;
        ------------------------------------------
        -- Input
        ------------------------------------------
        in_valid    : in  std_logic;
        in_data     : in  std_logic_vector(cl_fix_width(in_fmt_g)-1 downto 0);
        ------------------------------------------
        -- Output
        ------------------------------------------
        out_valid   : out std_logic;
        out_data    : out std_logic_vector(cl_fix_width(out_fmt_g)-1 downto 0)
    );
end en_cl_fix_resize;

---------------------------------------------------------------------------------------------------
-- Architecture
---------------------------------------------------------------------------------------------------
architecture rtl of en_cl_fix_resize is
    
    constant round_fmt_c    : FixFormat_t := cl_fix_round_fmt(in_fmt_g, out_fmt_g.F, round_g);
    
    signal round_valid      : std_logic;
    signal round_data       : std_logic_vector(cl_fix_width(round_fmt_c)-1 downto 0);
    
begin
    
    -----------
    -- Round --
    -----------
    i_round : entity work.en_cl_fix_round
    generic map(
        in_fmt_g    => in_fmt_g,
        out_fmt_g   => round_fmt_c,
        round_g     => round_g,
        force_reg_g => force_reg_g
    )
    port map(
        -- Clock and Reset
        clk         => clk,
        rst         => rst,
        -- Input
        in_valid    => in_valid,
        in_data     => in_data,
        -- Output
        out_valid   => round_valid,
        out_data    => round_data
    );
    
    --------------
    -- Saturate --
    --------------
    i_saturate : entity work.en_cl_fix_saturate
    generic map(
        in_fmt_g    => round_fmt_c,
        out_fmt_g   => out_fmt_g,
        saturate_g  => saturate_g,
        force_reg_g => force_reg_g
    )
    port map(
        -- Clock and Reset
        clk         => clk,
        rst         => rst,
        -- Input
        in_valid    => round_valid,
        in_data     => round_data,
        -- Output
        out_valid   => out_valid,
        out_data    => out_data
    );
    
end rtl;
