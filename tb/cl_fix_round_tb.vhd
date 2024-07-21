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

library vunit_lib;
    context vunit_lib.vunit_context;
    context vunit_lib.vc_context;

library en_tb;
    context en_tb.fileio_context;

library work;
    use work.en_cl_fix_pkg.all;
    use work.fix_fileio_pkg.all;

---------------------------------------------------------------------------------------------------
-- Entity
---------------------------------------------------------------------------------------------------
entity cl_fix_round_tb is
    generic(
        runner_cfg      : string
    );
end cl_fix_round_tb;

---------------------------------------------------------------------------------------------------
-- Architecture
---------------------------------------------------------------------------------------------------
architecture rtl of cl_fix_round_tb is

    constant datapath_c         : string := tb_path(runner_cfg) & "../bittrue/cosim/cl_fix_round/data/";
    
    -- Formats
    constant a_fmt_c            : FixFormatArray_t := cl_fix_read_format_file(datapath_c & "a_fmt.txt");
    constant r_fmt_c            : FixFormatArray_t := cl_fix_read_format_file(datapath_c & "r_fmt.txt");
    
    -- Rounding modes
    constant rnd_c              : integer_vector := read_file(datapath_c & "rnd.txt");
    
    constant test_count_c       : positive := a_fmt_c'length;
    
    signal clk                  : std_logic := '0';
    
    signal finished             : std_logic_vector(0 to test_count_c-1) := (others => '0');
    
    -- Helper function for printing error info
    function str(x : integer; x_fmt : FixFormat_t) return string is
    begin
        return to_string(cl_fix_to_real(cl_fix_from_integer(x, x_fmt), x_fmt));
    end function;
    
begin
    
    test_runner_watchdog(runner, 100 ms);
    
    clk <= not clk after 5 ns;
    
    ----------------
    -- VUnit Main --
    ----------------
    p_main : process
    begin
        test_runner_setup(runner, runner_cfg);
        
        while test_suite loop
            if run("test") then
                wait until (and finished) = '1';
            end if;
        end loop;
        
        print("SUCCESS! All tests passed.");
        test_runner_cleanup(runner);
    end process;
    
    -----------------------------------------------------------------------------------------------
    -- Test Cases
    -----------------------------------------------------------------------------------------------
    g_test_case : for i in 0 to test_count_c-1 generate
        constant Amin       : integer := cl_fix_to_integer(cl_fix_min_value(a_fmt_c(i)), a_fmt_c(i));
        constant Amax       : integer := cl_fix_to_integer(cl_fix_max_value(a_fmt_c(i)), a_fmt_c(i));
        
        signal rst          : std_logic;
        
        signal in_valid     : std_logic;
        signal in_data      : std_logic_vector(cl_fix_width(a_fmt_c(i))-1 downto 0);
        
        signal out_valid    : std_logic;
        signal out_data     : std_logic_vector(cl_fix_width(r_fmt_c(i))-1 downto 0);
    begin
        -----------
        -- Input --
        -----------
        p_input : process
        begin
            -- Reset
            rst <= '1';
            in_valid <= '0';
            wait until rising_edge(clk);
            rst <= '0';
            
            -- The cosim script generates all possible input values (counter).
            -- We repeat the same pattern here.
            for a in Amin to Amax loop
                in_valid <= '1';
                in_data <= cl_fix_from_integer(a, a_fmt_c(i));
                wait until rising_edge(clk);
            end loop;
            
            -- Idle
            in_valid <= '0';
            in_data <= (others => 'X');
            wait;
        end process;
        
        ---------
        -- UUT --
        ---------
        i_uut : entity work.en_cl_fix_round
        generic map(
            in_fmt_g    => a_fmt_c(i),
            out_fmt_g   => r_fmt_c(i),
            round_g     => FixRound_t'val(rnd_c(i)),
            force_reg_g => (i mod 2 = 0)  -- Toggle between test cases.
        )
        port map(
            -- Clock and Reset
            clk         => clk,
            rst         => rst,
            -- Input
            in_valid    => in_valid,
            in_data     => in_data,
            -- Output
            out_valid   => out_valid,
            out_data    => out_data
        );
        
        -------------
        -- Checker --
        -------------
        p_check : process
            constant Expected_c : SlvArray_t := cl_fix_read_file(DataPath_c & "test" & to_string(i) & "_output.txt", r_fmt_c(i));
            variable Idx_v      : natural := 0;
        begin
            for a in Amin to Amax loop
                wait until out_valid = '1' and rising_edge(Clk);
                
                -- Check against cosim
                if out_data /= Expected_c(Idx_v) then
                    print(
                        "Error in test case " & to_string(i) & " while rounding " & str(a, a_fmt_c(i)) & " " & to_string(a_fmt_c(i))
                        & " [rnd: " & to_string(FixRound_t'val(rnd_c(i))) & "] --> " & to_string(r_fmt_c(i))
                    );
                    check_equal(out_data, Expected_c(Idx_v), "Error at index " & to_string(Idx_v));
                end if;
                
                Idx_v := Idx_v + 1;
            end loop;
            
            finished(i) <= '1';
        end process;
    end generate;
end rtl;
