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
-- Description:
--
-- File I/O support for en_cl_fix.
--
-- This package provides wrappers around en_tb.fileio_text_pkg for en_cl_fix.
--
-- A short summary is provided for quick reference:
--
-- ================================================================================================
-- Data Reading
-- ================================================================================================
--     ------------------------------
--     Read data from std.textio.line
--     ------------------------------
--         cl_fix_read(L, x, fmt, [mode])
--     ------------------------------
--     Read data from std.textio.text
--     ------------------------------
--         x := cl_fix_read(f, fmt, [mode], [skip_before], [close_after])
--     --------------------
--     Read whole data file
--     --------------------
--         x := cl_fix_read_file(filename, fmt, [mode], [skip])
-- ================================================================================================
-- FixFormat_t Reading
-- ================================================================================================
--     -------------------------------------
--     Read FixFormat_t from std.textio.line
--     -------------------------------------
--         cl_fix_read_format(L, fmt)
--     -------------------------------------
--     Read FixFormat_t from std.textio.text
--     -------------------------------------
--         fmt := cl_fix_read_format(f, [skip_before], [close_after])
--     ---------------------------
--     Read whole FixFormat_t file
--     ---------------------------
--         fmt := cl_fix_read_format_file(filename, [skip])
-- ================================================================================================
-- Data Writing
-- ================================================================================================
--     -----------------------------
--     Write data to std.textio.line
--     -----------------------------
--         cl_fix_write(L, x, fmt, [mode])
--     -----------------------------
--     Write data to std.textio.text
--     -----------------------------
--         cl_fix_write(f, x, fmt, [mode])
--     ---------------------
--     Write whole data file
--     ---------------------
--         cl_fix_write_file(filename, x, fmt, [mode], [header])
-- ================================================================================================
-- FixFormat_t Writing
-- ================================================================================================
--     ------------------------------------
--     Write FixFormat_t to std.textio.line
--     ------------------------------------
--         cl_fix_write_format(L, fmt)
--     ------------------------------------
--     Write FixFormat_t to std.textio.text
--     ------------------------------------
--         cl_fix_write_format(f, fmt)
--     ----------------------------
--     Write whole FixFormat_t file
--     ----------------------------
--         cl_fix_write_format_file(filename, fmts)
--
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Libraries
---------------------------------------------------------------------------------------------------
library std;
    use std.textio.all;

library ieee;
    use ieee.std_logic_1164.all;

library en_tb;
    use en_tb.base_pkg.all;
    use en_tb.fileio_text_pkg.all;

library work;
    use work.en_cl_fix_pkg.all;

---------------------------------------------------------------------------------------------------
-- Package
---------------------------------------------------------------------------------------------------
package fix_fileio_pkg is
    
    -----------------------------------------------------------------------------------------------
    -- Read Access
    -----------------------------------------------------------------------------------------------
    
    -----------------------------------------
    -- Read EN_CL_FIX Data From Text Files --
    -----------------------------------------
    
    -- Parse ASCII text line as a single fixed-point value
    procedure cl_fix_read(
        variable L          : inout line;
        variable Data       : out   ieee.std_logic_1164.std_logic_vector;
        constant Fmt        : in    FixFormat_t;
        constant TextMode   : in    text_data_mode_t := ascii_dec
    );
    
    -- Read a single fixed-point value from a single-column ASCII text file
    impure function cl_fix_read(
        file     F          : text;
        constant Fmt        : FixFormat_t;
        constant TextMode   : text_data_mode_t := ascii_dec;
        constant SkipBefore : natural := 0;
        constant CloseAfter : boolean := false
    ) return std_logic_vector;
    
    -- Read a whole text file containing fixed-point data
    impure function cl_fix_read_file(
        constant Filename   : in string;
        constant Fmt        : in FixFormat_t;
        constant TextMode   : in text_data_mode_t := ascii_dec;
        constant SkipLines  : in natural := 1
    ) return SlvArray_t;
    
    ------------------------------------------------
    -- Read EN_CL_FIX FixFormat_t From Text Files --
    ------------------------------------------------
    
    -- Parse ASCII text line as a single FixFormat_t
    procedure cl_fix_read_format(
        variable L          : inout line;
        variable Fmt        : out   FixFormat_t
    );
    
    -- Read a single FixFormat_t from a single-column ASCII text file
    impure function cl_fix_read_format(
        file F              : text;
        constant SkipBefore : natural := 0;
        constant CloseAfter : boolean := false
    ) return FixFormat_t;
    
    -- Read a whole text file containing a single column of FixFormat_t strings
    impure function cl_fix_read_format_file(
        constant Filename   : in string;
        constant SkipLines  : in natural := 1
    ) return FixFormatArray_t;
    
    -----------------------------------------------------------------------------------------------
    -- Write Access
    -----------------------------------------------------------------------------------------------
    
    ----------------------------------------
    -- Write EN_CL_FIX Data To Text Files --
    ----------------------------------------
    
    -- Write a single fixed-point value to a text line
    procedure cl_fix_write(
        variable L          : inout line;
        constant Data       : in    std_logic_vector;
        constant Fmt        : in    FixFormat_t;
        constant TextMode   : in    text_data_mode_t := ascii_dec
    );
    
    -- Write a single fixed-point value to a text file
    procedure cl_fix_write(
        file     F          : text;
        constant Data       : in    std_logic_vector;
        constant Fmt        : in    FixFormat_t;
        constant TextMode   : in    text_data_mode_t := ascii_dec
    );
    
    -- Write a whole text file of fixed-point data
    procedure cl_fix_write_file(
        constant Filename   : in  string;
        constant Data       : in  SlvArray_t;
        constant Fmt        : in  FixFormat_t;
        constant TextMode   : in  text_data_mode_t := ascii_dec;
        constant Header     : in  string := ""
    );
    
    -----------------------------------------------
    -- Write EN_CL_FIX FixFormat_t To Text Files --
    -----------------------------------------------
    
    -- Write a single FixFormat_t to a text line
    procedure cl_fix_write_format(
        variable L          : inout line;
        constant Fmt        : in FixFormat_t
    );
    
    -- Write a single FixFormat_t to a text file
    procedure cl_fix_write_format(
        file F          : text;
        constant Fmt    : in FixFormat_t
    );
    
    -- Write an array of FixFormat_t strings to a text file
    procedure cl_fix_write_format_file(
        constant Filename   : in string;
        constant Formats    : in FixFormatArray_t
    );
    
end package;

---------------------------------------------------------------------------------------------------
-- Package Body
---------------------------------------------------------------------------------------------------
package body fix_fileio_pkg is
    
    -----------------------------------------------------------------------------------------------
    -- Private Functions
    -----------------------------------------------------------------------------------------------
    
    -- Helper function to determine Signedness_t from FixFormat_t
    function cl_fix_to_signedness(constant Fmt : in FixFormat_t) return Signedness_t is
    begin
        if Fmt.S = 1 then
            return Signed_s;
        else
            return Unsigned_s;
        end if;
    end function;
    
    -----------------------------------------------------------------------------------------------
    -- Read Access
    -----------------------------------------------------------------------------------------------
    
    -----------------------------------------
    -- Read EN_CL_FIX Data From Text Files --
    -----------------------------------------
    
    -- Parse ASCII text line as a single fixed-point value
    procedure cl_fix_read(
        variable L          : inout line;
        variable Data       : out   ieee.std_logic_1164.std_logic_vector;
        constant Fmt        : in    FixFormat_t;
        constant TextMode   : in    text_data_mode_t := ascii_dec
    ) is
    begin
        read(L, Data, cl_fix_to_signedness(Fmt), TextMode);
    end procedure;
    
    -- Read a single fixed-point value from a single-column ASCII text file
    impure function cl_fix_read(
        file     F          : text;
        constant Fmt        : FixFormat_t;
        constant TextMode   : text_data_mode_t := ascii_dec;
        constant SkipBefore : natural := 0;
        constant CloseAfter : boolean := false
    ) return std_logic_vector is
        variable Line_v     : line;
        variable Value_v    : std_logic_vector(cl_fix_width(Fmt)-1 downto 0);
    begin
        skip_lines(F, SkipBefore);
        readline(F, Line_v);
        cl_fix_read(Line_v, Value_v, Fmt, TextMode);
        deallocate(Line_v);
        if CloseAfter then
            file_close(F);
        end if;
        return Value_v;
    end function;
    
    -- Read a whole text file containing fixed-point data
    impure function cl_fix_read_file(
        constant Filename   : in string;
        constant Fmt        : in FixFormat_t;
        constant TextMode   : in text_data_mode_t := ascii_dec;
        constant SkipLines  : in natural := 1
    ) return SlvArray_t is
    begin
        return read_file(Filename, cl_fix_width(Fmt), cl_fix_to_signedness(Fmt), TextMode, SkipLines);
    end function;
    
    ------------------------------------------------
    -- Read EN_CL_FIX FixFormat_t From Text Files --
    ------------------------------------------------
    
    -- Parse ASCII text line as a single FixFormat_t
    procedure cl_fix_read_format(
        variable L          : inout line;
        variable Fmt        : out   FixFormat_t
    ) is
    begin
        Fmt := cl_fix_format_from_string(L.all);
        L := new string'("");
    end procedure;
    
    -- Read a single FixFormat_t from a single-column ASCII text file
    impure function cl_fix_read_format(
        file F              : text;
        constant SkipBefore : natural := 0;
        constant CloseAfter : boolean := false
    ) return FixFormat_t is
        variable Line_v     : line;
        variable Fmt_v      : FixFormat_t;
    begin
        skip_lines(F, SkipBefore);
        readline(F, Line_v);
        cl_fix_read_format(Line_v, Fmt_v);
        deallocate(Line_v);
        if CloseAfter then
            file_close(F);
        end if;
        return Fmt_v;
    end function;
    
    -- Read a whole text file containing a single column of FixFormat_t strings
    impure function cl_fix_read_format_file(
        constant Filename   : in string;
        constant SkipLines  : in natural := 1
    ) return FixFormatArray_t is
        constant FormatCount_c  : positive := get_file_size_lines(Filename) - SkipLines;
        file     F              : text;
        variable Line_v         : line;
        variable Formats_v      : FixFormatArray_t(0 to FormatCount_c-1);
    begin
        file_open(F, Filename, read_mode);
        -- Discard header lines
        skip_lines(F, SkipLines);
        -- Read formats
        for i in 0 to FormatCount_c-1 loop
            Formats_v(i) := cl_fix_read_format(F);
        end loop;
        deallocate(Line_v);
        file_close(F);
        return Formats_v;
    end function;
    
    -----------------------------------------------------------------------------------------------
    -- Write Access
    -----------------------------------------------------------------------------------------------
    
    ----------------------------------------
    -- Write EN_CL_FIX Data To Text Files --
    ----------------------------------------
    
    -- Write a single fixed-point value to a text line
    procedure cl_fix_write(
        variable L          : inout line;
        constant Data       : in    std_logic_vector;
        constant Fmt        : in    FixFormat_t;
        constant TextMode   : in    text_data_mode_t := ascii_dec
    ) is
    begin
        write(L, Data, cl_fix_to_signedness(Fmt), TextMode);
    end procedure;
    
    -- Write a single fixed-point value to a text file
    procedure cl_fix_write(
        file     F          : text;
        constant Data       : in    std_logic_vector;
        constant Fmt        : in    FixFormat_t;
        constant TextMode   : in    text_data_mode_t := ascii_dec
    ) is
    begin
        write(F, Data, cl_fix_to_signedness(Fmt), TextMode);
    end procedure;
    
    -- Write a whole text file of fixed-point data
    procedure cl_fix_write_file(
        constant Filename   : in  string;
        constant Data       : in  SlvArray_t;
        constant Fmt        : in  FixFormat_t;
        constant TextMode   : in  text_data_mode_t := ascii_dec;
        constant Header     : in  string := ""
    ) is
    begin
        write_file(Filename, Data, cl_fix_to_signedness(Fmt), TextMode, Header);
    end procedure;
    
    -----------------------------------------------
    -- Write EN_CL_FIX FixFormat_t To Text Files --
    -----------------------------------------------
    
    -- Write a single FixFormat_t to a text line
    procedure cl_fix_write_format(
        variable L          : inout line;
        constant Fmt        : in FixFormat_t
    ) is
    begin
        write(L, to_string(Fmt));
    end procedure;
    
    -- Write a single FixFormat_t to a text file
    procedure cl_fix_write_format(
        file F          : text;
        constant Fmt    : in FixFormat_t
    ) is
        variable Line_v     : line;
    begin
        cl_fix_write_format(Line_v, Fmt);
        writeline(F, Line_v);
        deallocate(Line_v);
    end procedure;
    
    -- Write an array of FixFormat_t strings to a text file
    procedure cl_fix_write_format_file(
        constant Filename   : in string;
        constant Formats    : in FixFormatArray_t
    ) is
        file F          : text;
    begin
        file_open(F, Filename, write_mode);
        for i in Formats'range loop
            cl_fix_write_format(F, Formats(i));
        end loop;
        file_close(F);
    end procedure;
    
end package body;
