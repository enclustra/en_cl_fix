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
entity cl_fix_compare_tb is
    generic(
        runner_cfg      : string
    );
end cl_fix_compare_tb;

---------------------------------------------------------------------------------------------------
-- Architecture
---------------------------------------------------------------------------------------------------
architecture rtl of cl_fix_compare_tb is

    constant DataPath_c         : string := tb_path(runner_cfg) & "../bittrue/cosim/cl_fix_compare/data/";
    
    -- Formats
    constant AFmt_c             : FixFormatArray_t := cl_fix_read_format_file(DataPath_c & "a_fmt.txt");
    constant BFmt_c             : FixFormatArray_t := cl_fix_read_format_file(DataPath_c & "b_fmt.txt");
    
    constant TestCount_c        : positive := AFmt_c'length;
    
    signal Clk                  : std_logic := '0';
    
    -- Helper function for printing error info
    function Str(x : integer; XFmt : FixFormat_t) return string is
    begin
        return to_string(cl_fix_to_real(cl_fix_from_integer(x, XFmt), XFmt));
    end function;
    
    function ToBool(x : integer) return boolean is
    begin
        if x = 1 then
            return true;
        end if;
        return false;
    end function;
    
    procedure Check(i : natural) is
        -- Load response data for this test case
        constant Eq_c       : integer_vector := read_file(DataPath_c & "test" & to_string(i) & "_eq.txt");
        constant Neq_c      : integer_vector := read_file(DataPath_c & "test" & to_string(i) & "_neq.txt");
        constant Less_c     : integer_vector := read_file(DataPath_c & "test" & to_string(i) & "_less.txt");
        constant Greater_c  : integer_vector := read_file(DataPath_c & "test" & to_string(i) & "_greater.txt");
        constant Leq_c      : integer_vector := read_file(DataPath_c & "test" & to_string(i) & "_leq.txt");
        constant Geq_c      : integer_vector := read_file(DataPath_c & "test" & to_string(i) & "_geq.txt");
        
        constant Amin       : integer := cl_fix_to_integer(cl_fix_min_value(AFmt_c(i)), AFmt_c(i));
        constant Amax       : integer := cl_fix_to_integer(cl_fix_max_value(AFmt_c(i)), AFmt_c(i));
        constant Bmin       : integer := cl_fix_to_integer(cl_fix_min_value(BFmt_c(i)), BFmt_c(i));
        constant Bmax       : integer := cl_fix_to_integer(cl_fix_max_value(BFmt_c(i)), BFmt_c(i));
        variable Idx_v      : natural := 0;
        variable Expected_v : boolean;
        variable Result_v   : boolean;
    begin
        -- The cosim script generates all possible values of both inputs (counters).
        -- We repeat the same pattern here.
        for b in Bmin to Bmax loop
            for a in Amin to Amax loop
                
                ---------------
                -- Compare = --
                ---------------
                
                -- Calculate result in VHDL
                Result_v := cl_fix_compare(
                    "=",
                    cl_fix_from_integer(a, AFmt_c(i)), AFmt_c(i),
                    cl_fix_from_integer(b, BFmt_c(i)), BFmt_c(i)
                );
                
                -- Check against cosim
                Expected_v := ToBool(Eq_c(Idx_v));
                if Result_v /= Expected_v then
                    print("Error for " & Str(a, AFmt_c(i)) & " " & to_string(AFmt_c(i)) & " = " & Str(b, BFmt_c(i)) & " " & to_string(BFmt_c(i)));
                    check_equal(Result_v, Expected_v, "Error at index " & to_string(Idx_v));
                end if;
                
                ----------------
                -- Compare != --
                ----------------
                
                -- Calculate result in VHDL
                Result_v := cl_fix_compare(
                    "!=",
                    cl_fix_from_integer(a, AFmt_c(i)), AFmt_c(i),
                    cl_fix_from_integer(b, BFmt_c(i)), BFmt_c(i)
                );
                
                -- Check against cosim
                Expected_v := ToBool(Neq_c(Idx_v));
                if Result_v /= Expected_v then
                    print("Error for " & Str(a, AFmt_c(i)) & " " & to_string(AFmt_c(i)) & " != " & Str(b, BFmt_c(i)) & " " & to_string(BFmt_c(i)));
                    check_equal(Result_v, Expected_v, "Error at index " & to_string(Idx_v));
                end if;
                
                ---------------
                -- Compare < --
                ---------------
                
                -- Calculate result in VHDL
                Result_v := cl_fix_compare(
                    "<",
                    cl_fix_from_integer(a, AFmt_c(i)), AFmt_c(i),
                    cl_fix_from_integer(b, BFmt_c(i)), BFmt_c(i)
                );
                
                -- Check against cosim
                Expected_v := ToBool(Less_c(Idx_v));
                if Result_v /= Expected_v then
                    print("Error for " & Str(a, AFmt_c(i)) & " " & to_string(AFmt_c(i)) & " < " & Str(b, BFmt_c(i)) & " " & to_string(BFmt_c(i)));
                    check_equal(Result_v, Expected_v, "Error at index " & to_string(Idx_v));
                end if;
                
                ---------------
                -- Compare > --
                ---------------
                
                -- Calculate result in VHDL
                Result_v := cl_fix_compare(
                    ">",
                    cl_fix_from_integer(a, AFmt_c(i)), AFmt_c(i),
                    cl_fix_from_integer(b, BFmt_c(i)), BFmt_c(i)
                );
                
                -- Check against cosim
                Expected_v := ToBool(Greater_c(Idx_v));
                if Result_v /= Expected_v then
                    print("Error for " & Str(a, AFmt_c(i)) & " " & to_string(AFmt_c(i)) & " > " & Str(b, BFmt_c(i)) & " " & to_string(BFmt_c(i)));
                    check_equal(Result_v, Expected_v, "Error at index " & to_string(Idx_v));
                end if;
                
                ----------------
                -- Compare <= --
                ----------------
                
                -- Calculate result in VHDL
                Result_v := cl_fix_compare(
                    "<=",
                    cl_fix_from_integer(a, AFmt_c(i)), AFmt_c(i),
                    cl_fix_from_integer(b, BFmt_c(i)), BFmt_c(i)
                );
                
                -- Check against cosim
                Expected_v := ToBool(Leq_c(Idx_v));
                if Result_v /= Expected_v then
                    print("Error for " & Str(a, AFmt_c(i)) & " " & to_string(AFmt_c(i)) & " <= " & Str(b, BFmt_c(i)) & " " & to_string(BFmt_c(i)));
                    check_equal(Result_v, Expected_v, "Error at index " & to_string(Idx_v));
                end if;
                
                ----------------
                -- Compare >= --
                ----------------
                
                -- Calculate result in VHDL
                Result_v := cl_fix_compare(
                    ">=",
                    cl_fix_from_integer(a, AFmt_c(i)), AFmt_c(i),
                    cl_fix_from_integer(b, BFmt_c(i)), BFmt_c(i)
                );
                
                -- Check against cosim
                Expected_v := ToBool(Geq_c(Idx_v));
                if Result_v /= Expected_v then
                    print("Error for " & Str(a, AFmt_c(i)) & " " & to_string(AFmt_c(i)) & " >= " & Str(b, BFmt_c(i)) & " " & to_string(BFmt_c(i)));
                    check_equal(Result_v, Expected_v, "Error at index " & to_string(Idx_v));
                end if;
                
                Idx_v := Idx_v + 1;
                
                -- We don't really need a clock, but it avoids iteration limits in the simulator
                -- (and avoids confusion for a developer seeing the time stuck at 0 ns).
                wait until rising_edge(Clk);
            end loop;
        end loop;
    end procedure;
    
begin
    
    test_runner_watchdog(runner, 100 ms);
    
    Clk <= not Clk after 5 ns;
    
    ----------------
    -- VUnit Main --
    ----------------
    p_main : process
    begin
        test_runner_setup(runner, runner_cfg);
        
        wait until rising_edge(Clk);
        
        while test_suite loop
            if run("test") then
                for i in 0 to TestCount_c-1 loop
                    Check(i);
                end loop;
            end if;
        end loop;
        
        print("SUCCESS! All tests passed.");
        test_runner_cleanup(runner);
    end process;
    
end rtl;
