---------------------------------------------------------------------------------------------------
-- Copyright (c) 2025 Enclustra GmbH, Switzerland (info@enclustra.com)
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
-- If reg_mode_g = Auto_s, then a pipeline register is only inserted when required. This is usually
-- the best choice when it is acceptable for latency to change when other generics are changed.
-- Latency = cl_fix_recommended_pipelining(in_fmt_g, out_fmt_g, round_g, saturate_g).
--
-- If reg_mode_g = Yes_s, then a pipeline register is always inserted. This is the best choice when
-- latency needs to be constant, regardless of all other generics. Latency = 2.
--
-- If reg_mode_g = No_s, then a pipeline register is never inserted. This is usually a bad choice
-- because it will typically degrade timing performance. Use with caution. Latency = 0.
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
        in_fmt_g        : FixFormat_t;
        out_fmt_g       : FixFormat_t;
        round_g         : FixRound_t;
        saturate_g      : FixSaturate_t;
        reg_mode_g      : RegisterMode_t;  -- See comments above. If unsure, set to Yes_s.
        meta_width_g    : natural := 0     -- Sideband metadata width. Default: unused.
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
        in_meta     : in  std_logic_vector(meta_width_g-1 downto 0) := (others => 'X');
        in_data     : in  std_logic_vector(cl_fix_width(in_fmt_g)-1 downto 0);
        ------------------------------------------
        -- Output
        ------------------------------------------
        out_valid   : out std_logic;
        out_meta    : out std_logic_vector(meta_width_g-1 downto 0);
        out_data    : out std_logic_vector(cl_fix_width(out_fmt_g)-1 downto 0)
    );
end en_cl_fix_resize;

---------------------------------------------------------------------------------------------------
-- Architecture
---------------------------------------------------------------------------------------------------
architecture rtl of en_cl_fix_resize is
    
    constant round_fmt_c    : FixFormat_t := cl_fix_round_fmt(in_fmt_g, out_fmt_g.F, round_g);
    
    signal round_valid      : std_logic;
    signal round_meta       : std_logic_vector(meta_width_g-1 downto 0);
    signal round_data       : std_logic_vector(cl_fix_width(round_fmt_c)-1 downto 0);
    
begin
    
    -----------
    -- Round --
    -----------
    i_round : entity work.en_cl_fix_round
    generic map(
        in_fmt_g        => in_fmt_g,
        out_fmt_g       => round_fmt_c,
        round_g         => round_g,
        reg_mode_g      => reg_mode_g,
        meta_width_g    => meta_width_g
    )
    port map(
        -- Clock and Reset
        clk         => clk,
        rst         => rst,
        -- Input
        in_valid    => in_valid,
        in_meta     => in_meta,
        in_data     => in_data,
        -- Output
        out_valid   => round_valid,
        out_meta    => round_meta,
        out_data    => round_data
    );
    
    --------------
    -- Saturate --
    --------------
    i_saturate : entity work.en_cl_fix_saturate
    generic map(
        in_fmt_g        => round_fmt_c,
        out_fmt_g       => out_fmt_g,
        saturate_g      => saturate_g,
        reg_mode_g      => reg_mode_g,
        meta_width_g    => meta_width_g
    )
    port map(
        -- Clock and Reset
        clk         => clk,
        rst         => rst,
        -- Input
        in_valid    => round_valid,
        in_meta     => round_meta,
        in_data     => round_data,
        -- Output
        out_valid   => out_valid,
        out_meta    => out_meta,
        out_data    => out_data
    );
    
end rtl;
