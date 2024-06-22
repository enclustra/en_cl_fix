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
-- Text file reading and writing.
--
-- The text files can contain numbers in any supported base:
--     text_data_mode_t is (ascii_bin, ascii_dec, ascii_hex)
--
-- Many VHDL data types are supported. For non-numeric types (e.g. std_logic_vector), it is
-- required to explicitly specify the signedness of the numbers in the file:
--     Signedness_t is (Unsigned_s, Signed_s);
--
-- Important: This file is very verbose. We tried to use VHDL-2008 generic subprograms to make it
-- more concise, but simulator support was extremely weak (in all of: Modelsim, Questa and GHDL).
--
-- A short summary is provided for quick reference:
--
-- ================================================================================================
-- Read Access
-- ================================================================================================
--     -------------------------------
--     Read value from std.textio.line
--     -------------------------------
--         Numeric types:
--             read(L, x, [mode])
--         Non-numeric types:
--             read(L, x, signedness, [mode])
--     -------------------------------
--     Read value from std.textio.text
--     -------------------------------
--         Numeric types:
--             read(f, x, [mode], [skip_before], [close_after])
--             x := read(f, n_bits, [mode], [skip_before], [close_after])
--         Non-numeric types:
--             read(f, x, signedness, [mode], [skip_before], [close_after])
--             x := read(f, n_bits, signedness, [mode], [skip_before], [close_after])
--     ---------------
--     Read whole file
--     ---------------
--         Numeric types:
--             x := read_file(filename, n_bits, [mode], [skip])
--         Non-numeric types:
--             x := read_file(filename, n_bits, signedness, [mode], [skip])
--
-- ================================================================================================
-- Write Access
-- ================================================================================================
--     ------------------------------
--     Write value to std.textio.line
--     ------------------------------
--         Numeric types:
--             write(L, x, [mode])
--         Non-numeric types:
--             write(L, x, signedness, [mode])
--     ------------------------------
--     Write value to std.textio.text
--     ------------------------------
--         Numeric types:
--             write(f, x, [mode])
--         Non-numeric types:
--             write(f, x, signedness, [mode])
--     ----------------
--     Write whole file
--     ----------------
--         Numeric types:
--             write_file(filename, x, [mode], [header])
--         Non-numeric types:
--             write_file(filename, x, signedness, [mode], [header])
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Libraries
---------------------------------------------------------------------------------------------------
library std;
    use std.textio.all;

library ieee;
    use ieee.numeric_bit.all;
    use ieee.numeric_std.all;

library work;
    use work.base_pkg.all;
    use work.fileio_text_private_pkg.all;

---------------------------------------------------------------------------------------------------
-- Package
---------------------------------------------------------------------------------------------------
package fileio_text_pkg is
    
    -----------
    -- Types --
    -----------
    
    -- (ascii_bin, ascii_dec, ascii_hex)
    alias text_data_mode_t is work.fileio_text_private_pkg.text_data_mode_t;
    
    ----------------------------
    -- File Utility Functions --
    ----------------------------
    
    -- Skip n lines in a file
    procedure skip_lines(file f : text; n : natural);
    
    -- Get file size in lines. (For ASCII files)
    -- Warning! This function iterates through the whole file, so avoid using for large files.
    impure function get_file_size_lines(filename : string) return integer;
    
    -- Get file size in columns. (For ASCII files)
    -- Note: This only checks the first line and assumes all others are the same
    impure function get_file_size_columns(
        filename    : string;
        skip        : natural := 1;
        mode        : text_data_mode_t := ascii_dec
    ) return integer;
    
    -----------------
    -- Read Access --
    -----------------
    
    -- PROCEDURE READ(LINE)
    procedure read(
        variable L          : inout line;
        variable x          : out   ieee.numeric_bit.signed;
        constant mode       : in    text_data_mode_t := ascii_dec
    );
    
    procedure read(
        variable L          : inout line;
        variable x          : out   ieee.numeric_bit.unsigned;
        constant mode       : in    text_data_mode_t := ascii_dec
    );
    
    procedure read(
        variable L          : inout line;
        variable x          : out   ieee.numeric_std.signed;
        constant mode       : in    text_data_mode_t := ascii_dec
    );
    
    procedure read(
        variable L          : inout line;
        variable x          : out   ieee.numeric_std.unsigned;
        constant mode       : in    text_data_mode_t := ascii_dec
    );
    
    procedure read(
        variable L          : inout line;
        variable x          : out   integer;
        constant mode       : in    text_data_mode_t := ascii_dec
    );
    
    -- Non-numeric types must explicitly indicate signedness
    procedure read(
        variable L          : inout line;
        variable x          : out   ieee.std_logic_1164.std_logic_vector;
        constant signedness : in    Signedness_t;
        constant mode       : in    text_data_mode_t := ascii_dec
    );
    
    procedure read(
        variable L          : inout line;
        variable x          : out   bit_vector;
        constant signedness : in    Signedness_t;
        constant mode       : in    text_data_mode_t := ascii_dec
    );
    
    procedure read(
        variable L          : inout line;
        variable x          : out   ieee.std_logic_1164.std_logic;
        constant mode       : in    text_data_mode_t := ascii_dec
    );
    
    procedure read(
        variable L          : inout line;
        variable x          : out   bit;
        constant mode       : in    text_data_mode_t := ascii_dec
    );
    
    -- PROCEDURE READ(FILE)
    procedure read(
        file f                  : text;
        variable x              : out ieee.numeric_bit.signed;
        constant mode           : in  text_data_mode_t := ascii_dec;
        constant skip_before    : in  natural := 0;
        constant close_after    : in  boolean := false
    );
    
    procedure read(
        file f                  : text;
        variable x              : out ieee.numeric_bit.unsigned;
        constant mode           : in  text_data_mode_t := ascii_dec;
        constant skip_before    : in  natural := 0;
        constant close_after    : in  boolean := false
    );
    
    procedure read(
        file f                  : text;
        variable x              : out ieee.numeric_std.signed;
        constant mode           : in  text_data_mode_t := ascii_dec;
        constant skip_before    : in  natural := 0;
        constant close_after    : in  boolean := false
    );
    
    procedure read(
        file f                  : text;
        variable x              : out ieee.numeric_std.unsigned;
        constant mode           : in  text_data_mode_t := ascii_dec;
        constant skip_before    : in  natural := 0;
        constant close_after    : in  boolean := false
    );
    
    procedure read(
        file f                  : text;
        variable x              : out integer;
        constant mode           : in  text_data_mode_t := ascii_dec;
        constant skip_before    : in  natural := 0;
        constant close_after    : in  boolean := false
    );
    
    -- Non-numeric types must explicitly indicate signedness
    procedure read(
        file f                  : text;
        variable x              : out ieee.std_logic_1164.std_logic_vector;
        constant signedness     : in  Signedness_t;
        constant mode           : in  text_data_mode_t := ascii_dec;
        constant skip_before    : in  natural := 0;
        constant close_after    : in  boolean := false
    );
    
    procedure read(
        file f                  : text;
        variable x              : out bit_vector;
        constant signedness     : in  Signedness_t;
        constant mode           : in  text_data_mode_t := ascii_dec;
        constant skip_before    : in  natural := 0;
        constant close_after    : in  boolean := false
    );
    
    procedure read(
        file f                  : text;
        variable x              : out ieee.std_logic_1164.std_logic;
        constant mode           : in  text_data_mode_t := ascii_dec;
        constant skip_before    : in  natural := 0;
        constant close_after    : in  boolean := false
    );
    
    procedure read(
        file f                  : text;
        variable x              : out bit;
        constant mode           : in  text_data_mode_t := ascii_dec;
        constant skip_before    : in  natural := 0;
        constant close_after    : in  boolean := false
    );
    
    -- FUNCTION READ(FILE)
    impure function read(
        file f                  : text;
        constant n_bits         : positive;
        constant mode           : text_data_mode_t := ascii_dec;
        constant skip_before    : natural := 0;
        constant close_after    : boolean := false
    ) return ieee.numeric_bit.signed;
    
    impure function read(
        file f                  : text;
        constant n_bits         : positive;
        constant mode           : text_data_mode_t := ascii_dec;
        constant skip_before    : natural := 0;
        constant close_after    : boolean := false
    ) return ieee.numeric_bit.unsigned;
    
    impure function read(
        file f                  : text;
        constant n_bits         : positive;
        constant mode           : text_data_mode_t := ascii_dec;
        constant skip_before    : natural := 0;
        constant close_after    : boolean := false
    ) return ieee.numeric_std.signed;
    
    impure function read(
        file f                  : text;
        constant n_bits         : positive;
        constant mode           : text_data_mode_t := ascii_dec;
        constant skip_before    : natural := 0;
        constant close_after    : boolean := false
    ) return ieee.numeric_std.unsigned;
    
    impure function read(
        file f                  : text;
        constant mode           : text_data_mode_t := ascii_dec;
        constant skip_before    : natural := 0;
        constant close_after    : boolean := false
    ) return integer;
    
    -- Non-numeric types must explicitly indicate signedness
    impure function read(
        file f                  : text;
        constant signedness     : signedness_t;
        constant n_bits         : positive;
        constant mode           : text_data_mode_t := ascii_dec;
        constant skip_before    : natural := 0;
        constant close_after    : boolean := false
    ) return ieee.std_logic_1164.std_logic_vector;
    
    impure function read(
        file f                  : text;
        constant signedness     : signedness_t;
        constant n_bits         : positive;
        constant mode           : text_data_mode_t := ascii_dec;
        constant skip_before    : natural := 0;
        constant close_after    : boolean := false
    ) return bit_vector;
    
    impure function read(
        file f                  : text;
        constant signedness     : signedness_t;
        constant n_bits         : positive;
        constant mode           : text_data_mode_t := ascii_dec;
        constant skip_before    : natural := 0;
        constant close_after    : boolean := false
    ) return ieee.std_logic_1164.std_logic;
    
    impure function read(
        file f                  : text;
        constant signedness     : signedness_t;
        constant n_bits         : positive;
        constant mode           : text_data_mode_t := ascii_dec;
        constant skip_before    : natural := 0;
        constant close_after    : boolean := false
    ) return bit;
    
    -- FUNCTION READ_FILE(FILENAME)
    impure function read_file(
        constant filename   : in  string;
        constant n_bits     : in  positive;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant skip       : in  natural := 1
    ) return SignedBitArray_t;
    
    impure function read_file(
        constant filename   : in  string;
        constant n_bits     : in  positive;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant skip       : in  natural := 1
    ) return UnsignedBitArray_t;
    
    impure function read_file(
        constant filename   : in  string;
        constant n_bits     : in  positive;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant skip       : in  natural := 1
    ) return SignedArray_t;
    
    impure function read_file(
        constant filename   : in  string;
        constant n_bits     : in  positive;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant skip       : in  natural := 1
    ) return UnsignedArray_t;
    
    impure function read_file(
        constant filename   : in  string;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant skip       : in  natural := 1
    ) return integer_vector;
    
    -- Non-numeric types must explicitly indicate signedness
    impure function read_file(
        constant filename   : in  string;
        constant n_bits     : in  positive;
        constant signedness : in  Signedness_t;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant skip       : in  natural := 1
    ) return BitVectorArray_t;
    
    impure function read_file(
        constant filename   : in  string;
        constant n_bits     : in  positive;
        constant signedness : in  Signedness_t;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant skip       : in  natural := 1
    ) return SlvArray_t;
    
    impure function read_file(
        constant filename   : in  string;
        constant n_bits     : in  positive;
        constant signedness : in  Signedness_t;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant skip       : in  natural := 1
    ) return SulvArray_t;
    
    ------------------
    -- Write Access --
    ------------------
    
    -- PROCEDURE WRITE(LINE)
    procedure write(
        variable L          : inout line;
        constant x          : in    ieee.numeric_bit.signed;
        constant mode       : in    text_data_mode_t := ascii_dec
    );
    
    procedure write(
        variable L          : inout line;
        constant x          : in    ieee.numeric_bit.unsigned;
        constant mode       : in    text_data_mode_t := ascii_dec
    );

    procedure write(
        variable L          : inout line;
        constant x          : in    ieee.numeric_std.signed;
        constant mode       : in    text_data_mode_t := ascii_dec
    );
    
    procedure write(
        variable L          : inout line;
        constant x          : in    ieee.numeric_std.unsigned;
        constant mode       : in    text_data_mode_t := ascii_dec
    );
    
    procedure write(
        variable L          : inout line;
        constant x          : in    integer;
        constant mode       : in    text_data_mode_t := ascii_dec
    );
    
    -- Non-numeric types must explicitly indicate signedness
    procedure write(
        variable L          : inout line;
        constant x          : in    ieee.std_logic_1164.std_logic_vector;
        constant signedness : in    Signedness_t;
        constant mode       : in    text_data_mode_t := ascii_dec
    );
    
    procedure write(
        variable L          : inout line;
        constant x          : in    bit_vector;
        constant signedness : in    Signedness_t;
        constant mode       : in    text_data_mode_t := ascii_dec
    );
    
    -- PROCEDURE WRITE(FILE)
    procedure write(
        file f              : text;
        constant x          : in ieee.numeric_bit.signed;
        constant mode       : in text_data_mode_t := ascii_dec
    );
    
    procedure write(
        file f              : text;
        constant x          : in ieee.numeric_bit.unsigned;
        constant mode       : in text_data_mode_t := ascii_dec
    );
    
    procedure write(
        file f              : text;
        constant x          : in ieee.numeric_std.signed;
        constant mode       : in text_data_mode_t := ascii_dec
    );
    
    procedure write(
        file f              : text;
        constant x          : in ieee.numeric_std.unsigned;
        constant mode       : in text_data_mode_t := ascii_dec
    );
    
    -- Non-numeric types must explicitly indicate signedness
    procedure write(
        file f              : text;
        constant x          : in ieee.std_logic_1164.std_logic_vector;
        constant signedness : in Signedness_t;
        constant mode       : in text_data_mode_t := ascii_dec
    );
    
    procedure write(
        file f              : text;
        constant x          : in bit_vector;
        constant signedness : in Signedness_t;
        constant mode       : in text_data_mode_t := ascii_dec
    );
    
    -- PROCEDURE WRITE_FILE(FILENAME)
    procedure write_file(
        constant filename   : in  string;
        constant data       : in  SignedBitArray_t;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant header     : in  string := ""
    );
    
    procedure write_file(
        constant filename   : in  string;
        constant data       : in  UnsignedBitArray_t;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant header     : in  string := ""
    );
    
    procedure write_file(
        constant filename   : in  string;
        constant data       : in  SignedArray_t;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant header     : in  string := ""
    );
    
    procedure write_file(
        constant filename   : in  string;
        constant data       : in  UnsignedArray_t;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant header     : in  string := ""
    );
    
    procedure write_file(
        constant filename   : in  string;
        constant data       : in  integer_vector;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant header     : in  string := ""
    );
    
    -- Non-numeric types must explicitly indicate signedness
    procedure write_file(
        constant filename   : in  string;
        constant data       : in  BitVectorArray_t;
        constant signedness : in  Signedness_t;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant header     : in  string := ""
    );
    
    procedure write_file(
        constant filename   : in  string;
        constant data       : in  SlvArray_t;
        constant signedness : in  Signedness_t;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant header     : in  string := ""
    );
    
    procedure write_file(
        constant filename   : in  string;
        constant data       : in  SulvArray_t;
        constant signedness : in  Signedness_t;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant header     : in  string := ""
    );
    
end package;

---------------------------------------------------------------------------------------------------
-- Package Body
---------------------------------------------------------------------------------------------------
package body fileio_text_pkg is
    
    -----------------------------------------------------------------------------------------------
    -- File Utility Functions
    -----------------------------------------------------------------------------------------------
    
    -- Skip n lines in a file
    procedure skip_lines(file f : text; n : natural) is
        variable line_v : line;
    begin
        for i in 0 to n-1 loop
            readline(f, line_v);
        end loop;
        deallocate(line_v);
    end;
    
    -- Get file size in lines. (Useful for ASCII files)
    -- Warning! This function iterates through the whole file, so avoid using for large files.
    impure function get_file_size_lines(filename : string) return integer is
        file f      : text;
        variable n  : integer := 0;
        variable L  : line;
    begin
        file_open(f, filename, read_mode);
        while not endfile(f) loop
            readline(f, L);
            n := n + 1;
        end loop;
        file_close(f);
        deallocate(L);
        return n;
    end function;
    
    -- Get file size in columns.
    -- Note: This only checks the first line and assumes all others are the same
    impure function get_file_size_columns(
        filename    : string;
        skip        : natural := 1;
        mode        : text_data_mode_t := ascii_dec
    ) return integer is
        file f      : text;
        variable L  : line;
        
        -- Nested helper function to deallocate line before returning string
        impure function get_string return string is
            constant s  : string := L.all;
        begin
            deallocate(L);
            return s;
        end function;
    begin
        file_open(f, filename, read_mode);
        
        -- Skip any metadata lines
        skip_lines(f, skip);
        
        -- Just read the first data line of the file
        readline(f, L);
        file_close(f);
        
        return get_ascii_columns(get_string, mode);
    end function;
    
    -----------------------------------------------------------------------------------------------
    -- Read Access
    -----------------------------------------------------------------------------------------------
    
    -- PROCEDURE READ(LINE)
    procedure read(
        variable L          : inout line;
        variable x          : out   ieee.numeric_bit.signed;
        constant mode       : in    text_data_mode_t := ascii_dec
    ) is
    begin
        case mode is
            when ascii_bin => ieee.numeric_bit.read(L, x);
            when ascii_dec => dread(L, x);
            when ascii_hex => hread_safe(L, x);
            when others => report "Unsupported mode " & to_string(mode) severity Failure;
        end case;
    end procedure;
    
    procedure read(
        variable L          : inout line;
        variable x          : out   ieee.numeric_bit.unsigned;
        constant mode       : in    text_data_mode_t := ascii_dec
    ) is
    begin
        case mode is
            when ascii_bin => ieee.numeric_bit.read(L, x);
            when ascii_dec => dread(L, x);
            when ascii_hex => hread(L, x);
            when others => report "Unsupported mode " & to_string(mode) severity Failure;
        end case;
    end procedure;
    
    procedure read(
        variable L          : inout line;
        variable x          : out   ieee.numeric_std.signed;
        constant mode       : in    text_data_mode_t := ascii_dec
    ) is
    begin
        case mode is
            when ascii_bin => ieee.numeric_std.read(L, x);
            when ascii_dec => dread(L, x);
            when ascii_hex => hread_safe(L, x);
            when others => report "Unsupported mode " & to_string(mode) severity Failure;
        end case;
    end procedure;
    
    procedure read(
        variable L          : inout line;
        variable x          : out   ieee.numeric_std.unsigned;
        constant mode       : in    text_data_mode_t := ascii_dec
    ) is
    begin
        case mode is
            when ascii_bin => ieee.numeric_std.read(L, x);
            when ascii_dec => dread(L, x);
            when ascii_hex => hread(L, x);
            when others => report "Unsupported mode " & to_string(mode) severity Failure;
        end case;
    end procedure;
    
    procedure read(
        variable L          : inout line;
        variable x          : out   integer;
        constant mode       : in    text_data_mode_t := ascii_dec
    ) is
        variable v  : ieee.numeric_bit.signed(31 downto 0);
    begin
        read(L, v, mode);
        x := ieee.numeric_bit.to_integer(v);
    end procedure;
    
    -- Non-numeric types must explicitly indicate signedness
    procedure read(
        variable L          : inout line;
        variable x          : out   bit_vector;
        constant signedness : in    Signedness_t;
        constant mode       : in    text_data_mode_t := ascii_dec
    ) is
        variable xu_v       : ieee.numeric_bit.unsigned(x'range);
        variable xs_v       : ieee.numeric_bit.signed(x'range);
    begin
        if signedness = Signed_s then
            read(L, xs_v, mode);
            x := bit_vector(xs_v);
        else
            read(L, xu_v, mode);
            x := bit_vector(xu_v);
        end if;
    end procedure;
    
    procedure read(
        variable L          : inout line;
        variable x          : out   ieee.std_logic_1164.std_logic_vector;
        constant signedness : in    Signedness_t;
        constant mode       : in    text_data_mode_t := ascii_dec
    ) is
        variable xu_v       : ieee.numeric_std.unsigned(x'range);
        variable xs_v       : ieee.numeric_std.signed(x'range);
    begin
        if signedness = Signed_s then
            read(L, xs_v, mode);
            x := ieee.std_logic_1164.std_logic_vector(xs_v);
        else
            read(L, xu_v, mode);
            x := ieee.std_logic_1164.std_logic_vector(xu_v);
        end if;
    end procedure;
    
    procedure read(
        variable L          : inout line;
        variable x          : out   ieee.std_logic_1164.std_logic;
        constant mode       : in    text_data_mode_t := ascii_dec
    ) is
        variable data_v     : ieee.std_logic_1164.std_logic_vector(0 downto 0);
    begin
        read(L, data_v, Unsigned_s, mode);
        x := data_v(0);
    end procedure;
    
    procedure read(
        variable L          : inout line;
        variable x          : out   bit;
        constant mode       : in    text_data_mode_t := ascii_dec
    ) is
        variable data_v     : bit_vector(0 downto 0);
    begin
        read(L, data_v, Unsigned_s, mode);
        x := data_v(0);
    end procedure;
    
    -- PROCEDURE READ(FILE)
    procedure read(
        file f                  : text;
        variable x              : out ieee.numeric_bit.signed;
        constant mode           : in  text_data_mode_t := ascii_dec;
        constant skip_before    : in  natural := 0;
        constant close_after    : in  boolean := false
    ) is
        variable line_v     : line;
    begin
        skip_lines(f, skip_before);
        readline(f, line_v);
        read(line_v, x, mode);
        deallocate(line_v);
        if close_after then
            file_close(f);
        end if;
    end procedure;
    
    procedure read(
        file f                  : text;
        variable x              : out ieee.numeric_bit.unsigned;
        constant mode           : in  text_data_mode_t := ascii_dec;
        constant skip_before    : in  natural := 0;
        constant close_after    : in  boolean := false
    ) is
        variable line_v     : line;
    begin
        skip_lines(f, skip_before);
        readline(f, line_v);
        read(line_v, x, mode);
        deallocate(line_v);
        if close_after then
            file_close(f);
        end if;
    end procedure;
    
    procedure read(
        file f                  : text;
        variable x              : out ieee.numeric_std.signed;
        constant mode           : in  text_data_mode_t := ascii_dec;
        constant skip_before    : in  natural := 0;
        constant close_after    : in  boolean := false
    ) is
        variable line_v     : line;
    begin
        skip_lines(f, skip_before);
        readline(f, line_v);
        read(line_v, x, mode);
        deallocate(line_v);
        if close_after then
            file_close(f);
        end if;
    end procedure;
    
    procedure read(
        file f                  : text;
        variable x              : out ieee.numeric_std.unsigned;
        constant mode           : in  text_data_mode_t := ascii_dec;
        constant skip_before    : in  natural := 0;
        constant close_after    : in  boolean := false
    ) is
        variable line_v     : line;
    begin
        skip_lines(f, skip_before);
        readline(f, line_v);
        read(line_v, x, mode);
        deallocate(line_v);
        if close_after then
            file_close(f);
        end if;
    end procedure;
    
    procedure read(
        file f                  : text;
        variable x              : out integer;
        constant mode           : in  text_data_mode_t := ascii_dec;
        constant skip_before    : in  natural := 0;
        constant close_after    : in  boolean := false
    ) is
        variable line_v     : line;
    begin
        skip_lines(f, skip_before);
        readline(f, line_v);
        read(line_v, x, mode);
        deallocate(line_v);
        if close_after then
            file_close(f);
        end if;
    end procedure;
    
    -- Non-numeric types must explicitly indicate signedness
    procedure read(
        file f                  : text;
        variable x              : out ieee.std_logic_1164.std_logic_vector;
        constant signedness     : in Signedness_t;
        constant mode           : in  text_data_mode_t := ascii_dec;
        constant skip_before    : in  natural := 0;
        constant close_after    : in  boolean := false
    ) is
        variable line_v     : line;
    begin
        skip_lines(f, skip_before);
        readline(f, line_v);
        read(line_v, x, signedness, mode);
        deallocate(line_v);
        if close_after then
            file_close(f);
        end if;
    end procedure;
    
    procedure read(
        file f                  : text;
        variable x              : out bit_vector;
        constant signedness     : in Signedness_t;
        constant mode           : in  text_data_mode_t := ascii_dec;
        constant skip_before    : in  natural := 0;
        constant close_after    : in  boolean := false
    ) is
        variable line_v     : line;
    begin
        skip_lines(f, skip_before);
        readline(f, line_v);
        read(line_v, x, signedness, mode);
        deallocate(line_v);
        if close_after then
            file_close(f);
        end if;
    end procedure;
    
    procedure read(
        file f                  : text;
        variable x              : out ieee.std_logic_1164.std_logic;
        constant mode           : in  text_data_mode_t := ascii_dec;
        constant skip_before    : in  natural := 0;
        constant close_after    : in  boolean := false
    ) is
        variable line_v     : line;
        variable data_v     : ieee.std_logic_1164.std_logic_vector(0 downto 0);
    begin
        read(f, data_v, Unsigned_s, mode, skip_before, close_after);
        x := data_v(0);
    end procedure;
    
    procedure read(
        file f                  : text;
        variable x              : out bit;
        constant mode           : in  text_data_mode_t := ascii_dec;
        constant skip_before    : in  natural := 0;
        constant close_after    : in  boolean := false
    ) is
        variable line_v     : line;
        variable data_v     : bit_vector(0 downto 0);
    begin
        read(f, data_v, Unsigned_s, mode, skip_before, close_after);
        x := data_v(0);
    end procedure;
    
    -- FUNCTION READ(FILE)
    impure function read(
        file f                  : text;
        constant n_bits         : positive;
        constant mode           : text_data_mode_t := ascii_dec;
        constant skip_before    : natural := 0;
        constant close_after    : boolean := false
    ) return ieee.numeric_bit.signed is
        variable data_v     : ieee.numeric_bit.signed(n_bits-1 downto 0);
    begin
        read(f, data_v, mode, skip_before, close_after);
        return data_v;
    end function;
    
    impure function read(
        file f                  : text;
        constant n_bits         : positive;
        constant mode           : text_data_mode_t := ascii_dec;
        constant skip_before    : natural := 0;
        constant close_after    : boolean := false
    ) return ieee.numeric_bit.unsigned is
        variable data_v     : ieee.numeric_bit.unsigned(n_bits-1 downto 0);
    begin
        read(f, data_v, mode, skip_before, close_after);
        return data_v;
    end function;
    
    impure function read(
        file f                  : text;
        constant n_bits         : positive;
        constant mode           : text_data_mode_t := ascii_dec;
        constant skip_before    : natural := 0;
        constant close_after    : boolean := false
    ) return ieee.numeric_std.signed is
        variable data_v     : ieee.numeric_std.signed(n_bits-1 downto 0);
    begin
        read(f, data_v, mode, skip_before, close_after);
        return data_v;
    end function;
    
    impure function read(
        file f                  : text;
        constant n_bits         : positive;
        constant mode           : text_data_mode_t := ascii_dec;
        constant skip_before    : natural := 0;
        constant close_after    : boolean := false
    ) return ieee.numeric_std.unsigned is
        variable data_v     : ieee.numeric_std.unsigned(n_bits-1 downto 0);
    begin
        read(f, data_v, mode, skip_before, close_after);
        return data_v;
    end function;
    
    impure function read(
        file f                  : text;
        constant mode           : text_data_mode_t := ascii_dec;
        constant skip_before    : natural := 0;
        constant close_after    : boolean := false
    ) return integer is
        variable data_v     : integer;
    begin
        read(f, data_v, mode, skip_before, close_after);
        return data_v;
    end function;
    
    -- Non-numeric types must explicitly indicate signedness
    impure function read(
        file f                  : text;
        constant signedness     : signedness_t;
        constant n_bits         : positive;
        constant mode           : text_data_mode_t := ascii_dec;
        constant skip_before    : natural := 0;
        constant close_after    : boolean := false
    ) return ieee.std_logic_1164.std_logic_vector is
        variable data_v     : ieee.std_logic_1164.std_logic_vector(n_bits-1 downto 0);
    begin
        read(f, data_v, signedness, mode, skip_before, close_after);
        return data_v;
    end function;
    
    impure function read(
        file f                  : text;
        constant signedness     : signedness_t;
        constant n_bits         : positive;
        constant mode           : text_data_mode_t := ascii_dec;
        constant skip_before    : natural := 0;
        constant close_after    : boolean := false
    ) return bit_vector is
        variable data_v     : bit_vector(n_bits-1 downto 0);
    begin
        read(f, data_v, signedness, mode, skip_before, close_after);
        return data_v;
    end function;
    
    impure function read(
        file f                  : text;
        constant signedness     : signedness_t;
        constant n_bits         : positive;
        constant mode           : text_data_mode_t := ascii_dec;
        constant skip_before    : natural := 0;
        constant close_after    : boolean := false
    ) return ieee.std_logic_1164.std_logic is
        variable data_v     : ieee.std_logic_1164.std_logic;
    begin
        read(f, data_v, mode, skip_before, close_after);
        return data_v;
    end function;
    
    impure function read(
        file f                  : text;
        constant signedness     : signedness_t;
        constant n_bits         : positive;
        constant mode           : text_data_mode_t := ascii_dec;
        constant skip_before    : natural := 0;
        constant close_after    : boolean := false
    ) return bit is
        variable data_v     : bit;
    begin
        read(f, data_v, mode, skip_before, close_after);
        return data_v;
    end function;
    
    -- FUNCTION READ_FILE(FILENAME)
    impure function read_file(
        constant filename   : in  string;
        constant n_bits     : in  positive;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant skip       : in  natural := 1
    ) return SignedBitArray_t is
        constant n_rows_c   : positive := get_file_size_lines(filename) - skip;
        constant n_cols_c   : positive := get_file_size_columns(filename, skip, mode);
        
        file f              : text;
        variable line_v     : line;
        variable data_v     : SignedBitArray_t(0 to n_rows_c*n_cols_c-1)(n_bits-1 downto 0);
    begin
        file_open(f, filename, read_mode);
        
        -- Skip header lines
        skip_lines(f, skip);
        
        for i in 0 to n_rows_c-1 loop
            assert not endfile(f) 
                report "Unexpected end of file after " & integer'image(i) & " lines"
                severity Failure;
                
            readline(f, line_v);
            
            for j in 0 to n_cols_c-1 loop
                assert line_v.all'length > 0
                    report "Unexpected end of line (line " & integer'image(i) & ", column " & integer'image(j) & ")"
                    severity Failure;
                
                read(line_v, data_v(i*n_cols_c + j), mode);
            end loop;
        end loop;
        
        -- Close the file
        file_close(f);
        
        return data_v;
    end function;
    
    impure function read_file(
        constant filename   : in  string;
        constant n_bits     : in  positive;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant skip       : in  natural := 1
    ) return UnsignedBitArray_t is
        constant n_rows_c   : positive := get_file_size_lines(filename) - skip;
        constant n_cols_c   : positive := get_file_size_columns(filename, skip, mode);
        
        file f              : text;
        variable line_v     : line;
        variable data_v     : UnsignedBitArray_t(0 to n_rows_c*n_cols_c-1)(n_bits-1 downto 0);
    begin
        file_open(f, filename, read_mode);
        
        -- Skip header lines
        skip_lines(f, skip);
        
        for i in 0 to n_rows_c-1 loop
            assert not endfile(f) 
                report "Unexpected end of file after " & integer'image(i) & " lines"
                severity Failure;
                
            readline(f, line_v);
            
            for j in 0 to n_cols_c-1 loop
                assert line_v.all'length > 0
                    report "Unexpected end of line (line " & integer'image(i) & ", column " & integer'image(j) & ")"
                    severity Failure;
                
                read(line_v, data_v(i*n_cols_c + j), mode);
            end loop;
        end loop;
        
        -- Close the file
        file_close(f);
        
        return data_v;
    end function;
    
    impure function read_file(
        constant filename   : in  string;
        constant n_bits     : in  positive;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant skip       : in  natural := 1
    ) return SignedArray_t is
        constant n_rows_c   : positive := get_file_size_lines(filename) - skip;
        constant n_cols_c   : positive := get_file_size_columns(filename, skip, mode);
        
        file f              : text;
        variable line_v     : line;
        variable data_v     : SignedArray_t(0 to n_rows_c*n_cols_c-1)(n_bits-1 downto 0);
    begin
        file_open(f, filename, read_mode);
        
        -- Skip header lines
        skip_lines(f, skip);
        
        for i in 0 to n_rows_c-1 loop
            assert not endfile(f) 
                report "Unexpected end of file after " & integer'image(i) & " lines"
                severity Failure;
                
            readline(f, line_v);
            
            for j in 0 to n_cols_c-1 loop
                assert line_v.all'length > 0
                    report "Unexpected end of line (line " & integer'image(i) & ", column " & integer'image(j) & ")"
                    severity Failure;
                
                read(line_v, data_v(i*n_cols_c + j), mode);
            end loop;
        end loop;
        
        -- Close the file
        file_close(f);
        
        return data_v;
    end function;
    
    impure function read_file(
        constant filename   : in  string;
        constant n_bits     : in  positive;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant skip       : in  natural := 1
    ) return UnsignedArray_t is
        constant n_rows_c   : positive := get_file_size_lines(filename) - skip;
        constant n_cols_c   : positive := get_file_size_columns(filename, skip, mode);
        
        file f              : text;
        variable line_v     : line;
        variable data_v     : UnsignedArray_t(0 to n_rows_c*n_cols_c-1)(n_bits-1 downto 0);
    begin
        file_open(f, filename, read_mode);
        
        -- Skip header lines
        skip_lines(f, skip);
        
        for i in 0 to n_rows_c-1 loop
            assert not endfile(f) 
                report "Unexpected end of file after " & integer'image(i) & " lines"
                severity Failure;
                
            readline(f, line_v);
            
            for j in 0 to n_cols_c-1 loop
                assert line_v.all'length > 0
                    report "Unexpected end of line (line " & integer'image(i) & ", column " & integer'image(j) & ")"
                    severity Failure;
                
                read(line_v, data_v(i*n_cols_c + j), mode);
            end loop;
        end loop;
        
        -- Close the file
        file_close(f);
        
        return data_v;
    end function;
    
    impure function read_file(
        constant filename   : in  string;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant skip       : in  natural := 1
    ) return integer_vector is
        constant n_rows_c   : positive := get_file_size_lines(filename) - skip;
        constant n_cols_c   : positive := get_file_size_columns(filename, skip, mode);
        
        file f              : text;
        variable line_v     : line;
        variable data_v     : integer_vector(0 to n_rows_c*n_cols_c-1);
    begin
        file_open(f, filename, read_mode);
        
        -- Skip header lines
        skip_lines(f, skip);
        
        for i in 0 to n_rows_c-1 loop
            assert not endfile(f) 
                report "Unexpected end of file after " & integer'image(i) & " lines"
                severity Failure;
                
            readline(f, line_v);
            
            for j in 0 to n_cols_c-1 loop
                assert line_v.all'length > 0
                    report "Unexpected end of line (line " & integer'image(i) & ", column " & integer'image(j) & ")"
                    severity Failure;
                
                read(line_v, data_v(i*n_cols_c + j), mode);
            end loop;
        end loop;
        
        -- Close the file
        file_close(f);
        
        return data_v;
    end function;
    
    -- Non-numeric types must explicitly indicate signedness
    impure function read_file(
        constant filename   : in  string;
        constant n_bits     : in  positive;
        constant signedness : in  Signedness_t;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant skip       : in  natural := 1
    ) return BitVectorArray_t is
        constant n_rows_c   : positive := get_file_size_lines(filename) - skip;
        constant n_cols_c   : positive := get_file_size_columns(filename, skip, mode);
        
        file f              : text;
        variable line_v     : line;
        variable data_v     : BitVectorArray_t(0 to n_rows_c*n_cols_c-1)(n_bits-1 downto 0);
    begin
        file_open(f, filename, read_mode);
        
        -- Skip header lines
        skip_lines(f, skip);
        
        for i in 0 to n_rows_c-1 loop
            assert not endfile(f) 
                report "Unexpected end of file after " & integer'image(i) & " lines"
                severity Failure;
                
            readline(f, line_v);
            
            for j in 0 to n_cols_c-1 loop
                assert line_v.all'length > 0
                    report "Unexpected end of line (line " & integer'image(i) & ", column " & integer'image(j) & ")"
                    severity Failure;
                
                read(line_v, data_v(i*n_cols_c + j), signedness, mode);
            end loop;
        end loop;
        
        -- Close the file
        file_close(f);
        
        return data_v;
    end function;
    
    impure function read_file(
        constant filename   : in  string;
        constant n_bits     : in  positive;
        constant signedness : in  Signedness_t;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant skip       : in  natural := 1
    ) return SlvArray_t is
        constant n_rows_c   : positive := get_file_size_lines(filename) - skip;
        constant n_cols_c   : positive := get_file_size_columns(filename, skip, mode);
        
        file f              : text;
        variable line_v     : line;
        variable data_v     : SlvArray_t(0 to n_rows_c*n_cols_c-1)(n_bits-1 downto 0);
    begin
        file_open(f, filename, read_mode);
        
        -- Skip header lines
        skip_lines(f, skip);
        
        for i in 0 to n_rows_c-1 loop
            assert not endfile(f) 
                report "Unexpected end of file after " & integer'image(i) & " lines"
                severity Failure;
                
            readline(f, line_v);
            
            for j in 0 to n_cols_c-1 loop
                assert line_v.all'length > 0
                    report "Unexpected end of line (line " & integer'image(i) & ", column " & integer'image(j) & ")"
                    severity Failure;
                
                read(line_v, data_v(i*n_cols_c + j), signedness, mode);
            end loop;
        end loop;
        
        -- Close the file
        file_close(f);
        
        return data_v;
    end function;
    
    impure function read_file(
        constant filename   : in  string;
        constant n_bits     : in  positive;
        constant signedness : in  Signedness_t;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant skip       : in  natural := 1
    ) return SulvArray_t is
        constant n_rows_c   : positive := get_file_size_lines(filename) - skip;
        constant n_cols_c   : positive := get_file_size_columns(filename, skip, mode);
        
        file f              : text;
        variable line_v     : line;
        variable data_v     : SulvArray_t(0 to n_rows_c*n_cols_c-1)(n_bits-1 downto 0);
    begin
        file_open(f, filename, read_mode);
        
        -- Skip header lines
        skip_lines(f, skip);
        
        for i in 0 to n_rows_c-1 loop
            assert not endfile(f) 
                report "Unexpected end of file after " & integer'image(i) & " lines"
                severity Failure;
                
            readline(f, line_v);
            
            for j in 0 to n_cols_c-1 loop
                assert line_v.all'length > 0
                    report "Unexpected end of line (line " & integer'image(i) & ", column " & integer'image(j) & ")"
                    severity Failure;
                
                read(line_v, data_v(i*n_cols_c + j), signedness, mode);
            end loop;
        end loop;
        
        -- Close the file
        file_close(f);
        
        return data_v;
    end function;
    
    -----------------------------------------------------------------------------------------------
    -- Write Access
    -----------------------------------------------------------------------------------------------
    
    -- PROCEDURE WRITE(LINE)
    procedure write(
        variable L          : inout line;
        constant x          : in    ieee.numeric_bit.signed;
        constant mode       : in    text_data_mode_t := ascii_dec
    ) is
    begin
        case mode is
            when ascii_bin => ieee.numeric_bit.write(L, x);
            when ascii_dec => dwrite(L, x);
            when ascii_hex => hwrite(L, x);
            when others => report "Unsupported mode " & to_string(mode) severity Failure;
        end case;
    end procedure;
    
    procedure write(
        variable L          : inout line;
        constant x          : in    ieee.numeric_bit.unsigned;
        constant mode       : in    text_data_mode_t := ascii_dec
    ) is
    begin
        case mode is
            when ascii_bin => ieee.numeric_bit.write(L, x);
            when ascii_dec => dwrite(L, x);
            when ascii_hex => hwrite(L, x);
            when others => report "Unsupported mode " & to_string(mode) severity Failure;
        end case;
    end procedure;

    procedure write(
        variable L          : inout line;
        constant x          : in    ieee.numeric_std.signed;
        constant mode       : in    text_data_mode_t := ascii_dec
    ) is
    begin
        case mode is
            when ascii_bin => ieee.numeric_std.write(L, x);
            when ascii_dec => dwrite(L, x);
            when ascii_hex => hwrite(L, x);
            when others => report "Unsupported mode " & to_string(mode) severity Failure;
        end case;
    end procedure;
    
    procedure write(
        variable L          : inout line;
        constant x          : in    ieee.numeric_std.unsigned;
        constant mode       : in    text_data_mode_t := ascii_dec
    ) is
    begin
        case mode is
            when ascii_bin => ieee.numeric_std.write(L, x);
            when ascii_dec => dwrite(L, x);
            when ascii_hex => hwrite(L, x);
            when others => report "Unsupported mode " & to_string(mode) severity Failure;
        end case;
    end procedure;
    
    procedure write(
        variable L          : inout line;
        constant x          : in    integer;
        constant mode       : in    text_data_mode_t := ascii_dec
    ) is
    begin
        write(L, ieee.numeric_bit.to_signed(x, 32), mode);
    end procedure;
    
    -- Non-numeric types must explicitly indicate signedness
    procedure write(
        variable L          : inout line;
        constant x          : in    ieee.std_logic_1164.std_logic_vector;
        constant signedness : in    Signedness_t;
        constant mode       : in    text_data_mode_t := ascii_dec
    ) is
    begin
        if signedness = Signed_s then
            write(L, ieee.numeric_std.signed(x), mode);
        else
            write(L, ieee.numeric_std.unsigned(x), mode);
        end if;
    end procedure;
    
    procedure write(
        variable L          : inout line;
        constant x          : in    bit_vector;
        constant signedness : in    Signedness_t;
        constant mode       : in    text_data_mode_t := ascii_dec
    ) is
    begin
        if signedness = Signed_s then
            write(L, ieee.numeric_bit.signed(x), mode);
        else
            write(L, ieee.numeric_bit.unsigned(x), mode);
        end if;
    end procedure;
    
    -- PROCEDURE WRITE(FILE)
    procedure write(
        file f              : text;
        constant x          : in ieee.numeric_bit.signed;
        constant mode       : in text_data_mode_t := ascii_dec
    ) is
        variable Line_v     : line;
    begin
        write(Line_v, x, mode);
        writeline(f, Line_v);
        deallocate(Line_v);
    end procedure;
    
    procedure write(
        file f              : text;
        constant x          : in ieee.numeric_bit.unsigned;
        constant mode       : in text_data_mode_t := ascii_dec
    ) is
        variable Line_v     : line;
    begin
        write(Line_v, x, mode);
        writeline(f, Line_v);
        deallocate(Line_v);
    end procedure;
    
    procedure write(
        file f              : text;
        constant x          : in ieee.numeric_std.signed;
        constant mode       : in text_data_mode_t := ascii_dec
    ) is
        variable Line_v     : line;
    begin
        write(Line_v, x, mode);
        writeline(f, Line_v);
        deallocate(Line_v);
    end procedure;
    
    procedure write(
        file f              : text;
        constant x          : in ieee.numeric_std.unsigned;
        constant mode       : in text_data_mode_t := ascii_dec
    ) is
        variable Line_v     : line;
    begin
        write(Line_v, x, mode);
        writeline(f, Line_v);
        deallocate(Line_v);
    end procedure;
    
    -- Non-numeric types must explicitly indicate signedness
    procedure write(
        file f              : text;
        constant x          : in ieee.std_logic_1164.std_logic_vector;
        constant signedness : in Signedness_t;
        constant mode       : in text_data_mode_t := ascii_dec
    ) is
        variable Line_v     : line;
    begin
        write(Line_v, x, signedness, mode);
        writeline(f, Line_v);
        deallocate(Line_v);
    end procedure;
    
    procedure write(
        file f              : text;
        constant x          : in bit_vector;
        constant signedness : in Signedness_t;
        constant mode       : in text_data_mode_t := ascii_dec
    ) is
        variable Line_v     : line;
    begin
        write(Line_v, x, signedness, mode);
        writeline(f, Line_v);
        deallocate(Line_v);
    end procedure;
    
    -- PROCEDURE WRITE_FILE(FILENAME)
    procedure write_file(
        constant filename   : in  string;
        constant data       : in  SignedBitArray_t;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant header     : in  string := ""
    ) is
        file f              : text;
        variable line_v     : line;
    begin
        file_open(f, filename, write_mode);
        
        -- Write the header
        if header'length > 0 then
            line_v := new string'(header);
            writeline(f, line_v);
        end if;
        
        for i in data'range loop
            write(line_v, data(i), mode);
            writeline(f, line_v);
        end loop;
        
        -- Close the file
        file_close(f);
    end procedure;
    
    procedure write_file(
        constant filename   : in  string;
        constant data       : in  UnsignedBitArray_t;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant header     : in  string := ""
    ) is
        file f              : text;
        variable line_v     : line;
    begin
        file_open(f, filename, write_mode);
        
        -- Write the header
        if header'length > 0 then
            line_v := new string'(header);
            writeline(f, line_v);
        end if;
        
        for i in data'range loop
            write(line_v, data(i), mode);
            writeline(f, line_v);
        end loop;
        
        -- Close the file
        file_close(f);
    end procedure;
    
    procedure write_file(
        constant filename   : in  string;
        constant data       : in  SignedArray_t;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant header     : in  string := ""
    ) is
        file f              : text;
        variable line_v     : line;
    begin
        file_open(f, filename, write_mode);
        
        -- Write the header
        if header'length > 0 then
            line_v := new string'(header);
            writeline(f, line_v);
        end if;
        
        for i in data'range loop
            write(line_v, data(i), mode);
            writeline(f, line_v);
        end loop;
        
        -- Close the file
        file_close(f);
    end procedure;
    
    procedure write_file(
        constant filename   : in  string;
        constant data       : in  UnsignedArray_t;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant header     : in  string := ""
    ) is
        file f              : text;
        variable line_v     : line;
    begin
        file_open(f, filename, write_mode);
        
        -- Write the header
        if header'length > 0 then
            line_v := new string'(header);
            writeline(f, line_v);
        end if;
        
        for i in data'range loop
            write(line_v, data(i), mode);
            writeline(f, line_v);
        end loop;
        
        -- Close the file
        file_close(f);
    end procedure;
    
    procedure write_file(
        constant filename   : in  string;
        constant data       : in  integer_vector;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant header     : in  string := ""
    ) is
        file f              : text;
        variable line_v     : line;
    begin
        file_open(f, filename, write_mode);
        
        -- Write the header
        if header'length > 0 then
            line_v := new string'(header);
            writeline(f, line_v);
        end if;
        
        for i in data'range loop
            write(line_v, data(i), mode);
            writeline(f, line_v);
        end loop;
        
        -- Close the file
        file_close(f);
    end procedure;
    
    -- Non-numeric types must explicitly indicate signedness
    procedure write_file(
        constant filename   : in  string;
        constant data       : in  BitVectorArray_t;
        constant signedness : in  Signedness_t;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant header     : in  string := ""
    ) is
        file f              : text;
        variable line_v     : line;
    begin
        file_open(f, filename, write_mode);
        
        -- Write the header
        if header'length > 0 then
            line_v := new string'(header);
            writeline(f, line_v);
        end if;
        
        for i in data'range loop
            write(line_v, data(i), signedness, mode);
            writeline(f, line_v);
        end loop;
        
        -- Close the file
        file_close(f);
    end procedure;
    
    procedure write_file(
        constant filename   : in  string;
        constant data       : in  SlvArray_t;
        constant signedness : in  Signedness_t;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant header     : in  string := ""
    ) is
        file f              : text;
        variable line_v     : line;
    begin
        file_open(f, filename, write_mode);
        
        -- Write the header
        if header'length > 0 then
            line_v := new string'(header);
            writeline(f, line_v);
        end if;
        
        for i in data'range loop
            write(line_v, data(i), signedness, mode);
            writeline(f, line_v);
        end loop;
        
        -- Close the file
        file_close(f);
    end procedure;
    
    procedure write_file(
        constant filename   : in  string;
        constant data       : in  SulvArray_t;
        constant signedness : in  Signedness_t;
        constant mode       : in  text_data_mode_t := ascii_dec;
        constant header     : in  string := ""
    ) is
        file f              : text;
        variable line_v     : line;
    begin
        file_open(f, filename, write_mode);
        
        -- Write the header
        if header'length > 0 then
            line_v := new string'(header);
            writeline(f, line_v);
        end if;
        
        for i in data'range loop
            write(line_v, data(i), signedness, mode);
            writeline(f, line_v);
        end loop;
        
        -- Close the file
        file_close(f);
    end procedure;
    
end package body;
