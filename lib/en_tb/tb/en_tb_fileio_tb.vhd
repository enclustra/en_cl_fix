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
library std;
    use std.textio.all;

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library vunit_lib;
    context vunit_lib.vunit_context;
    context vunit_lib.vc_context;

library en_tb;
    context en_tb.fileio_context;

---------------------------------------------------------------------------------------------------
-- Entity
---------------------------------------------------------------------------------------------------
entity en_tb_fileio_tb is
    generic(
        runner_cfg      : string;
        test_index_g    : natural
    );
end en_tb_fileio_tb;

---------------------------------------------------------------------------------------------------
-- Architecture
---------------------------------------------------------------------------------------------------
architecture rtl of en_tb_fileio_tb is
    -- File paths
    constant data_path_c        : string := tb_path(runner_cfg) & "../bittrue/cosim/en_tb_fileio/data/";
    constant test_prefix_c      : string := data_path_c & "test" & to_string(test_index_g) & "_";
    
    constant config_c           : integer_vector := read_file(test_prefix_c & "config.txt");
    constant data_width_c       : positive := config_c(0);
    constant file_columns_c     : positive := config_c(1);
    
    constant mode_count_c       : positive := 1 + text_data_mode_t'pos(text_data_mode_t'high);
    
    -- Arbitrarily choose one set of data as the "expected" reference
    constant ref_unsigned_c     : SlvArray_t := read_file(test_prefix_c & "ascii_dec_data_unsigned.txt", data_width_c, unsigned_s, ascii_dec);
    constant ref_signed_c       : SlvArray_t := read_file(test_prefix_c & "ascii_dec_data_signed.txt", data_width_c, signed_s, ascii_dec);
    
    function convert(x : SlvArray_t) return BitVectorArray_t is
        variable v : BitVectorArray_t(x'range)(x'element'range);
    begin
        for i in x'range loop
            v(i) := to_bit_vector(x(i));
        end loop;
        return v;
    end function;
    
    -- GHDL bug workaround. This replaces SlvArray_t(), which throws an error.
    function convert(x : UnsignedArray_t) return SlvArray_t is
        constant c  : SlvArray_t(x'range)(x'element'range) := SlvArray_t(x);
    begin
        return c;
    end function;
    
    -- GHDL bug workaround. This replaces SlvArray_t(), which throws an error.
    function convert(x : SignedArray_t) return SlvArray_t is
        constant c  : SlvArray_t(x'range)(x'element'range) := SlvArray_t(x);
    begin
        return c;
    end function;
    
    -- GHDL bug workaround. This replaces SlvArray_t(), which throws an error.
    function convert(x : SulvArray_t) return SlvArray_t is
        constant c  : SlvArray_t(x'range)(x'element'range) := SlvArray_t(x);
    begin
        return c;
    end function;
    
    -- GHDL bug workaround. This replaces BitVectorArray_t(), which fails silently.
    function convert(x : UnsignedBitArray_t) return BitVectorArray_t is
        constant c  : BitVectorArray_t(x'range)(x'element'range) := BitVectorArray_t(x);
    begin
        return c;
    end function;
    
    -- GHDL bug workaround. This replaces BitVectorArray_t(), which fails silently.
    function convert(x : SignedBitArray_t) return BitVectorArray_t is
        constant c  : BitVectorArray_t(x'range)(x'element'range) := BitVectorArray_t(x);
    begin
        return c;
    end function;
    
    signal stop     : std_logic_vector(0 to mode_count_c-1) := "000";
    
begin
    test_runner_watchdog(runner, 1 ns);
    
    p_main : process
    begin
        test_runner_setup(runner, runner_cfg);
        
        while test_suite loop
            if run("test") then
                while not (and stop) loop
                    wait for 1 ns;
                end loop;
            end if;
        end loop;
        
        print("Success: All tests passed.");
        test_runner_cleanup(runner);
        wait;
    end process;
    
    g_mode : for i in 0 to mode_count_c-1 generate
        constant mode_c             : text_data_mode_t := text_data_mode_t'val(i);
        constant mode_name_c        : string := to_string(mode_c);
        
        -- std_logic_vector
        constant data_uslv_c        : SlvArray_t := read_file(test_prefix_c & mode_name_c & "_data_unsigned.txt", data_width_c, unsigned_s, mode_c);
        constant data_sslv_c        : SlvArray_t := read_file(test_prefix_c & mode_name_c & "_data_signed.txt", data_width_c, signed_s, mode_c);
        
        -- numeric_std
        constant data_u_c           : UnsignedArray_t := read_file(test_prefix_c & mode_name_c & "_data_unsigned.txt", data_width_c, mode_c);
        constant data_s_c           : SignedArray_t := read_file(test_prefix_c & mode_name_c & "_data_signed.txt", data_width_c, mode_c);
        
        -- std_ulogic_vector
        constant data_usulv_c       : SulvArray_t := read_file(test_prefix_c & mode_name_c & "_data_unsigned.txt", data_width_c, unsigned_s, mode_c);
        constant data_ssulv_c       : SulvArray_t := read_file(test_prefix_c & mode_name_c & "_data_signed.txt", data_width_c, signed_s, mode_c);
        
        -- bit_vector
        constant data_ubit_c        : BitVectorArray_t := read_file(test_prefix_c & mode_name_c & "_data_unsigned.txt", data_width_c, unsigned_s, mode_c);
        constant data_sbit_c        : BitVectorArray_t := read_file(test_prefix_c & mode_name_c & "_data_signed.txt", data_width_c, signed_s, mode_c);
        
        -- numeric_bit
        constant data_uba_c         : UnsignedBitArray_t := read_file(test_prefix_c & mode_name_c & "_data_unsigned.txt", data_width_c, mode_c);
        constant data_sba_c         : SignedBitArray_t := read_file(test_prefix_c & mode_name_c & "_data_signed.txt", data_width_c, mode_c);
    begin
    
        process
        begin
            print("Starting " & mode_name_c & " tests...");
            
            ------------------
            -- File Reading --
            ------------------
            
            -- Check ordinary file reading and check values against the "expected" reference...
            
            check_equal(data_uslv_c, ref_unsigned_c, "USLV read mismatch");
            check_equal(data_sslv_c, ref_signed_c, "SSLV read mismatch");
            
            check_equal(convert(data_u_c), ref_unsigned_c, "U read mismatch");
            check_equal(convert(data_s_c), ref_signed_c, "S read mismatch");
            
            check_equal(convert(data_usulv_c), ref_unsigned_c, "USULV read mismatch");
            check_equal(convert(data_ssulv_c), ref_signed_c, "SSULV read mismatch");
            
            check_equal(data_ubit_c, convert(ref_unsigned_c), "SBIT read mismatch");
            check_equal(data_sbit_c, convert(ref_signed_c), "SBIT read mismatch");
            
            check_equal(convert(data_uba_c), convert(ref_unsigned_c), "UBA read mismatch");
            check_equal(convert(data_sba_c), convert(ref_signed_c), "SBA read mismatch");
            
            ------------------
            -- File Writing --
            ------------------
            write_file(test_prefix_c & mode_name_c & "_output_uslv.txt", data_uslv_c, unsigned_s, mode_c, "uslv");
            write_file(test_prefix_c & mode_name_c & "_output_sslv.txt", data_sslv_c, signed_s, mode_c, "sslv");
            
            write_file(test_prefix_c & mode_name_c & "_output_u.txt", data_u_c, mode_c, "u");
            write_file(test_prefix_c & mode_name_c & "_output_s.txt", data_s_c, mode_c, "s");
            
            write_file(test_prefix_c & mode_name_c & "_output_usulv.txt", data_usulv_c, unsigned_s, mode_c, "usulv");
            write_file(test_prefix_c & mode_name_c & "_output_ssulv.txt", data_ssulv_c, signed_s, mode_c, "ssulv");
            
            write_file(test_prefix_c & mode_name_c & "_output_ubit.txt", data_ubit_c, unsigned_s, mode_c, "ubit");
            write_file(test_prefix_c & mode_name_c & "_output_sbit.txt", data_sbit_c, signed_s, mode_c, "sbit");
            
            write_file(test_prefix_c & mode_name_c & "_output_uba.txt", data_uba_c, mode_c, "uba");
            write_file(test_prefix_c & mode_name_c & "_output_sba.txt", data_sba_c, mode_c, "sba");
            
            ---------------
            -- Read Back --
            ---------------
            
            -- Read back the files written above to check they were written correctly...
            
            check_equal(read_file(test_prefix_c & mode_name_c & "_output_uslv.txt", data_width_c, unsigned_s, mode_c), data_uslv_c, mode_name_c & ": USLV readback mismatch");
            check_equal(read_file(test_prefix_c & mode_name_c & "_output_sslv.txt", data_width_c, signed_s, mode_c), data_sslv_c, mode_name_c & ": SSLV readback mismatch");
            
            check_equal(read_file(test_prefix_c & mode_name_c & "_output_u.txt", data_width_c, mode_c), data_u_c, mode_name_c & ": U readback mismatch");
            check_equal(read_file(test_prefix_c & mode_name_c & "_output_s.txt", data_width_c, mode_c), data_s_c, mode_name_c & ": S readback mismatch");
            
            check_equal(read_file(test_prefix_c & mode_name_c & "_output_usulv.txt", data_width_c, unsigned_s, mode_c), data_usulv_c, mode_name_c & ": USULV readback mismatch");
            check_equal(read_file(test_prefix_c & mode_name_c & "_output_ssulv.txt", data_width_c, signed_s, mode_c), data_ssulv_c, mode_name_c & ": SSULV readback mismatch");
            
            check_equal(read_file(test_prefix_c & mode_name_c & "_output_ubit.txt", data_width_c, unsigned_s, mode_c), data_ubit_c, mode_name_c & ": UBIT readback mismatch");
            check_equal(read_file(test_prefix_c & mode_name_c & "_output_sbit.txt", data_width_c, signed_s, mode_c), data_sbit_c, mode_name_c & ": SBIT readback mismatch");
            
            check_equal(read_file(test_prefix_c & mode_name_c & "_output_uba.txt", data_width_c, mode_c), data_uba_c, mode_name_c & ": UBA readback mismatch");
            check_equal(read_file(test_prefix_c & mode_name_c & "_output_sba.txt", data_width_c, mode_c), data_sba_c, mode_name_c & ": SBA readback mismatch");
            
            stop(i) <= '1';
            wait;
        end process;
    end generate;
    
end rtl;
