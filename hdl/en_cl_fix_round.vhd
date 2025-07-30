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
-- This block implements pipelined rounding.
--
-- If reg_mode_g = Auto_s, then a pipeline register is only inserted when required. This is usually
-- the best choice when it is acceptable for latency to change when other generics are changed.
-- Latency = cl_fix_recommended_pipelining(in_fmt_g, out_fmt_g, round_g).
--
-- If reg_mode_g = Yes_s, then a pipeline register is always inserted. This is the best choice when
-- latency needs to be constant, regardless of all other generics. Latency = 1.
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
entity en_cl_fix_round is
    generic(
        in_fmt_g        : FixFormat_t;
        out_fmt_g       : FixFormat_t;
        round_g         : FixRound_t;
        reg_mode_g      : RegisterMode_t;  -- See comments above. If unsure, set to Yes_s.
        meta_width_g    : natural := 0;    -- Sideband metadata width. Default: unused.
        fmt_check_g     : boolean := true  -- See cl_fix_round.
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
end en_cl_fix_round;

---------------------------------------------------------------------------------------------------
-- Architecture
---------------------------------------------------------------------------------------------------
architecture rtl of en_cl_fix_round is
    
    constant recommended_c  : natural range 0 to 1 := cl_fix_recommended_pipelining(in_fmt_g, out_fmt_g, round_g, fmt_check_g);
    constant use_reg_c      : boolean := (reg_mode_g = Yes_s) or (reg_mode_g = Auto_s and recommended_c > 0);
    
    signal result           : std_logic_vector(cl_fix_width(out_fmt_g)-1 downto 0);
    
begin
    -- Calculate result
    result <= cl_fix_round(in_data, in_fmt_g, out_fmt_g, round_g, fmt_check_g);
    
    -- With pipeline register
    g_register : if use_reg_c generate
        process(clk)
        begin
            if rising_edge(clk) then
                out_valid <= in_valid and not rst;
                out_meta <= in_meta;
                out_data <= result;
            end if;
        end process;
    end generate;
    
    -- Without pipeline register
    g_no_register : if not use_reg_c generate
        out_valid <= in_valid;
        out_meta <= in_meta;
        out_data <= result;
    end generate;
    
end rtl;
