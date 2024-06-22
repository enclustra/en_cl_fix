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
-- Notes:
--
-- Internal functionality for fileio_text_pkg. Moved here to reduce clutter.
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Libraries
---------------------------------------------------------------------------------------------------
library std;
    use std.textio.all;

library ieee;
    use ieee.numeric_bit.all;

library work;
    use work.base_pkg.all;

---------------------------------------------------------------------------------------------------
-- Package
---------------------------------------------------------------------------------------------------
package fileio_text_private_pkg is
    
    -- File data storage modes (more can be added)
    type text_data_mode_t is (ascii_bin, ascii_dec, ascii_hex);
    
    -- Get number of data columns in ASCII string.
    impure function get_ascii_columns(s : string; mode : text_data_mode_t) return integer;
    
    -----------------------------------------------------------------------------------------------
    -- dwrite / dread
    -----------------------------------------------------------------------------------------------
    -- Utility functions for writing and reading (arbitrarily large) decimal values to and from
    -- text files.
    --
    -- Only VHDL integers natively support decimal text file I/O (which are limited to 32 bits).
    -- Numeric vector types natively support arbitrary data widths, but only in binary, octal and
    -- hex representations.
    
    -- Decimal write unsigned (ASCII), similar to ieee.numeric_bit *write procedures
    procedure dwrite(L : inout line; x : unsigned);
    
    -- Decimal write signed (ASCII), similar to ieee.numeric_bit *write procedures
    procedure dwrite(L : inout line; x : signed);
    
    -- Decimal read unsigned (ASCII), similar to ieee.numeric_bit *read procedures
    procedure dread(L : inout line; x : out unsigned);
    
    -- Decimal read signed (ASCII), similar to ieee.numeric_bit *read procedures
    procedure dread(L : inout line; x : out signed);
    
    -- Overloads of the numeric_bit functions
    procedure dwrite(L : inout line; x : ieee.numeric_std.unsigned);
    procedure dwrite(L : inout line; x : ieee.numeric_std.signed);
    procedure dread(L : inout line; x : out ieee.numeric_std.unsigned);
    procedure dread(L : inout line; x : out ieee.numeric_std.signed);
    
    -----------------------------------------------------------------------------------------------
    -- hread
    -----------------------------------------------------------------------------------------------
    
    -- Workarounds for HREAD sometimes failing if bit-width is not a multiple of 4.
    procedure hread_safe(L : inout line; x : out ieee.numeric_std.signed);
    procedure hread_safe(L : inout line; x : out signed);
    
end package;

---------------------------------------------------------------------------------------------------
-- Package Body
---------------------------------------------------------------------------------------------------
package body fileio_text_private_pkg is
    
    -----------------------------------------------------------------------------------------------
    -- Private Functions
    -----------------------------------------------------------------------------------------------
    
    -- Helper function to check if a character is numeric binary (0-1)
    function is_binary(c : character) return boolean is
    begin
        return c = '0' or c = '1';
    end function;
    
    -- Helper function to check if a character is numeric decimal (0-9)
    function is_decimal(c : character) return boolean is
    begin
        return character'pos(c) >= character'pos('0') and
               character'pos(c) <= character'pos('9');
    end function;
    
    -- Helper function to check if a character is numeric hex (0-F)
    function is_hexadecimal(c : character) return boolean is
    begin
        return is_decimal(c) or 
               (character'pos(c) >= character'pos('A') and
                character'pos(c) <= character'pos('F')) or
               (character'pos(c) >= character'pos('a') and
                character'pos(c) <= character'pos('f'));
    end function;
    
    -- Helper function to check if a character is numeric (for the specified mode)
    function is_numeric(c : character; mode : text_data_mode_t) return boolean is
    begin
        case mode is
            when ascii_bin => return is_binary(c);
            when ascii_dec => return is_decimal(c);
            when ascii_hex => return is_hexadecimal(c);
            when others => report "Unsupported mode " & to_string(mode) severity Failure;
        end case;
        return false;
    end function;
    
    -- Binary to Binary Coded Decimal conversion. This method is called "double dabble" or
    -- "shift-and-add-3": https://en.wikipedia.org/wiki/Double_dabble
    -- Reference: https://pubweb.eng.utah.edu/~nmcdonal/Tutorials/BCDTutorial/BCDConversion.html
    function bin_to_dec(b : unsigned; n_digits : positive) return integer_vector is
        constant n_bits_c   : positive := b'length;
        variable d          : unsigned(3 downto 0);
        variable v          : unsigned(4*n_digits+n_bits_c downto 0);
        variable v_next     : unsigned(4*n_digits+n_bits_c downto 0);
        variable v_int      : integer_vector(n_digits-1 downto 0);
    begin
        -- Initial shift
        v_next := shift_left((4*n_digits downto 0 => '0') & b, 1);
        
        for i in 1 to n_bits_c-1 loop
            v := v_next;
            for k in 0 to n_digits-1 loop
                -- Extract 4-bit digit for this stage
                d := v((k+1)*4+n_bits_c-1 downto k*4+n_bits_c);
                
                -- Add 3 if digit is >= 5
                if d >= 5 then
                    d := d + 3;
                end if;
                
                -- Write back, shifted left by 1
                v_next((k+1)*4+n_bits_c downto k*4+n_bits_c+1) := d;
            end loop;
            
            -- Always shift the LSBs along without modification
            v_next(n_bits_c downto 1) := v(n_bits_c-1 downto 0);
        end loop;
        
        -- Convert BCD digits to integers
        for k in 0 to n_digits-1 loop
            v_int(k) := to_integer(v_next((k+1)*4+n_bits_c-1 downto k*4+n_bits_c));
        end loop;
        
        return v_int;
    end function;
    
    -----------------------------------------------------------------------------------------------
    -- Public Functions
    -----------------------------------------------------------------------------------------------
    
    -- Get number of data columns in ASCII string.
    impure function get_ascii_columns(s : string; mode : text_data_mode_t) return integer is
        variable idx_v      : positive;
        variable count_v    : integer := 0;
    begin
        
        -- Note that for decimal base:
        --     We can't use read(L, x_integer) because our numbers may be > 32 bits.
        --     We can't use read(L, x_signed) because that expects binary strings.
        
        idx_v := s'low;
        while idx_v <= s'high loop
            if is_numeric(s(idx_v), mode) then
                -- Start of a new number
                count_v := count_v + 1;
                idx_v := idx_v + 1;
                -- Scan past all numeric digits in current number
                while idx_v <= s'high and is_numeric(s(idx_v), mode) loop
                    idx_v := idx_v + 1;
                end loop;
            else
                -- Scan past all non-numeric delimiter characters
                while idx_v <= s'high and not is_numeric(s(idx_v), mode) loop
                    idx_v := idx_v + 1;
                end loop;
            end if;
        end loop;
        
        return count_v;
    end function;
    
    -- Decimal write unsigned (ASCII), similar to ieee.numeric_bit *write procedures
    procedure dwrite(L : inout line; x : unsigned) is
        -- Ndigits = ceil(log10(2) * Nbits) = ceil(0.3010 * Nbits) = approx. ceil(Nbits / 3)
        constant n_digits_c : positive := (x'length + 2) / 3;
        constant digits_c   : integer_vector := bin_to_dec(x, n_digits_c);
    begin
        if L = null then
            L := new string'("");
        end if;
        for i in digits_c'high downto digits_c'low loop
            L := new string'(L.all & to_string(digits_c(i)));
        end loop;
    end procedure;
    
    -- Decimal write signed (ASCII), similar to ieee.numeric_bit *write procedures
    procedure dwrite(L : inout line; x : signed) is
    begin
        if x >= 0 then
            dwrite(L, unsigned(x));
        else
            L := new string'("-");            -- Insert "-" sign.
            dwrite(L, unsigned(-('1' & x)));  -- Sign extend before negating.
        end if;
    end procedure;
    
    -- Decimal read unsigned (ASCII), similar to ieee.numeric_bit *read procedures
    procedure dread(L : inout line; x : out unsigned) is
        constant nx       : positive := x'length;
        constant s        : string := L.all;
        variable w        : unsigned(x'range) := to_unsigned(1, nx);
        variable shigh_v  : positive := s'high;
    begin
        deallocate(L);
        
        -- Find the end of the number
        for i in s'low to s'high loop
            if not is_decimal(s(i)) then
                -- Note: An error on this line usually means the text line doesn't start with a
                --       number. For example, when trying to read a negative number as unsigned.
                --       We don't want to add a check because that will slow down execution.
                shigh_v := i-1;
                exit;
            end if;
        end loop;
        
        -- Note: This implementation is probably slow and we should call integer'value over
        --       multiple digits at a time. TODO.
        x := to_unsigned(0, nx);
        for i in shigh_v downto s'low loop
            -- Add contribution of this digit
            x := x + resize(integer'value(s(i to i)) * w, nx);
            if i > s'low then
                w := resize(w * 10, nx);  -- Update digit weight
            end if;
        end loop;
        
        -- Scan past any trailing non-numeric delimiters
        shigh_v := shigh_v + 1;
        while true loop
            if shigh_v > s'high or s(shigh_v) = '-' or is_decimal(s(shigh_v)) then
                exit;
            end if;
            shigh_v := shigh_v + 1;
        end loop;
        
        -- Discard the current number (and trailing delimiters) from text line
        L := new string'(s(shigh_v to s'high));
    end procedure;
    
    -- Decimal read signed (ASCII), similar to ieee.numeric_bit *read procedures
    procedure dread(L : inout line; x : out signed) is
        constant s      : string := L.all;
        variable vu     : unsigned(x'range);
        variable slow_v : integer := -1;
    begin
        deallocate(L);
        
        -- Find the start of the number
        for i in s'low to s'high loop
            if s(i) = '-' or is_decimal(s(i)) then
                slow_v := i;
                exit;
            end if;
        end loop;
        
        assert slow_v > 0 report "No numeric characters to read." severity Failure;
        
        if s(slow_v) = '-' then
            L := new string'(s(slow_v+1 to s'high));
            dread(L, vu);
            x := -signed(vu);
        else
            L := new string'(s(slow_v to s'high));
            dread(L, vu);
            x := signed(vu);
        end if;
    end procedure;
    
    -- Numeric_std overloads
    procedure dwrite(L : inout line; x : ieee.numeric_std.unsigned) is
    begin
        dwrite(L, unsigned(ieee.std_logic_1164.to_bit_vector(ieee.std_logic_1164.std_logic_vector(x))));
    end procedure;
    
    procedure dwrite(L : inout line; x : ieee.numeric_std.signed) is
    begin
        dwrite(L, signed(ieee.std_logic_1164.to_bit_vector(ieee.std_logic_1164.std_logic_vector(x))));
    end procedure;
    
    procedure dread(L : inout line; x : out ieee.numeric_std.unsigned) is
        variable v  : unsigned(x'range);
    begin
        dread(L, v);
        x := ieee.numeric_std.unsigned(ieee.std_logic_1164.to_std_logic_vector(bit_vector(v)));
    end procedure;
    
    procedure dread(L : inout line; x : out ieee.numeric_std.signed) is
        variable v  : signed(x'range);
    begin
        dread(L, v);
        x := ieee.numeric_std.signed(ieee.std_logic_1164.to_std_logic_vector(bit_vector(v)));
    end procedure;
    
    procedure hread_safe(L : inout line; x : out ieee.numeric_std.signed) is
        -- HREAD sometimes fails if bit-width is not a multiple of 4.
        constant hex_width_c    : positive := 4*((x'length+3)/4);  -- ceil(length/4)
        variable xhex_v         : ieee.numeric_std.signed(hex_width_c-1 downto 0);
    begin
        ieee.numeric_std.hread(L, xhex_v);
        x := xhex_v(x'length-1 downto 0);
    end procedure;
    
    procedure hread_safe(L : inout line; x : out signed) is
        -- HREAD sometimes fails if bit-width is not a multiple of 4.
        constant hex_width_c    : positive := 4*((x'length+3)/4);  -- ceil(length/4)
        variable xhex_v         : signed(hex_width_c-1 downto 0);
    begin
        hread(L, xhex_v);
        x := xhex_v(x'length-1 downto 0);
    end procedure;
    
end package body;
