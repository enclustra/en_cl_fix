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

---------------------------------------------------------------------------------------------------
-- Package Header
---------------------------------------------------------------------------------------------------
package en_cl_fix_private_pkg is
    
    function choose(condition : boolean; if_true : integer; if_false : integer) return integer;
    function choose(condition : boolean; if_true : std_logic; if_false : std_logic) return std_logic;
    function to01(x : std_logic) return std_logic;
    function to01(x : std_logic_vector) return std_logic_vector;
    function toInteger(bool : boolean) return integer;
    
    function maximum(a, b : integer) return integer;
    function minimum(a, b : integer) return integer;
    
    function toLower(s : string) return string;
    function string_find_next_match(Str : string; Char : character; StartIdx : natural) return integer;
    function string_parse_int(Str : string; StartIdx : natural) return integer;
    
end package;

---------------------------------------------------------------------------------------------------
-- Package Body
---------------------------------------------------------------------------------------------------
package body en_cl_fix_private_pkg is
    
    function choose(condition : boolean; if_true : integer; if_false : integer) return integer is
    begin
        if condition then
            return if_true;
        end if;
        return if_false;
    end function;
    
    function choose(condition : boolean; if_true : std_logic; if_false : std_logic) return std_logic is
    begin
        if condition then
            return if_true;
        end if;
        return if_false;
    end function;
    
    function to01(x : std_logic) return std_logic is
        variable result_v : std_logic;
    begin
        if x = '1' or x = 'H' then
            result_v := '1';
        else
            result_v := '0';
        end if;
        return result_v;
    end;
    
    function to01(x : std_logic_vector) return std_logic_vector is
        variable result_v : std_logic_vector(x'range);
    begin
        for i in x'range loop
            result_v(i) := to01(x(i));
        end loop;
        return result_v;
    end;
    
    function toInteger(bool : boolean) return integer is
    begin
        if bool then
            return 1;
        else
            return 0;
        end if;
    end;
    
    function maximum(a, b : integer) return integer is
    begin
        if a >= b then
            return a;
        else
            return b;
        end if;
    end;
    
    function minimum(a, b : integer) return integer is
    begin
        if a <= b then
            return a;
        else
            return b;
        end if;
    end;
    
    function toLower(c : character) return character is
        variable v : character;
    begin
        case c is
            when 'A' => v := 'a';
            when 'B' => v := 'b';
            when 'C' => v := 'c';
            when 'D' => v := 'd';
            when 'E' => v := 'e';
            when 'F' => v := 'f';
            when 'G' => v := 'g';
            when 'H' => v := 'h';
            when 'I' => v := 'i';
            when 'J' => v := 'j';
            when 'K' => v := 'k';
            when 'L' => v := 'l';
            when 'M' => v := 'm';
            when 'N' => v := 'n';
            when 'O' => v := 'o';
            when 'P' => v := 'p';
            when 'Q' => v := 'q';
            when 'R' => v := 'r';
            when 'S' => v := 's';
            when 'T' => v := 't';
            when 'U' => v := 'u';
            when 'V' => v := 'v';
            when 'W' => v := 'w';
            when 'X' => v := 'x';
            when 'Y' => v := 'y';
            when 'Z' => v := 'z';
            when others => v := c;
        end case;
        return v;
    end;
    
    function toLower(s : string) return string is
        variable v : string(s'range);
    begin
        for i in s'range loop
            v(i):= toLower(s(i));
        end loop;
        return v;
    end;
    
    function string_find_next_match(Str : string; Char : character; StartIdx : natural) return integer is
        variable CurrentIdx_v       : integer := StartIdx;
        variable Match_v            : boolean := false;
        variable MatchIdx_v         : integer := -1;
    begin
        -- Checks
        assert StartIdx <= Str'high and StartIdx >= Str'low report "string_find_next_match: StartIdx out of range" severity Failure;
        
        -- Implementation
        while (not Match_v) and (CurrentIdx_v <= Str'high) loop
            if Str(CurrentIdx_v) = Char then
                Match_v     := true;
                MatchIdx_v  := CurrentIdx_v;
            end if;
            CurrentIdx_v := CurrentIdx_v + 1;
        end loop;
        return MatchIdx_v;
    end function;
    
    function string_int_from_char(Char : character) return integer is
    begin
        case Char is
            when '0'    => return 0;
            when '1'    => return 1;
            when '2'    => return 2;
            when '3'    => return 3;
            when '4'    => return 4;
            when '5'    => return 5;
            when '6'    => return 6;
            when '7'    => return 7;
            when '8'    => return 8;
            when '9'    => return 9;
            when others => return -1;
        end case;
        return 0;
    end function;
    
    function string_char_is_numeric(Char : character) return boolean is
    begin
        return string_int_from_char(Char) /= -1;
    end function;
    
    function string_parse_int(Str : string; StartIdx : natural) return integer is
        variable CurrentIdx_v       : integer   := StartIdx;
        variable IsNegative_v       : boolean   := false;
        variable AbsoluteVal_v      : integer   := 0;
    begin
        -- Checks
        assert StartIdx <= Str'high and StartIdx >= Str'low report "string_parse_int: StartIdx out of range" severity Failure;
        
        -- Remove leading spaces
        while Str(CurrentIdx_v) = ' ' loop
            CurrentIdx_v := CurrentIdx_v + 1;
        end loop;
        
        -- Detect negative numbers
        if Str(CurrentIdx_v) = '-' then
            IsNegative_v := true;
            CurrentIdx_v := CurrentIdx_v + 1;
        end if;
        
        -- Parse absolute value
        while (CurrentIdx_v <= Str'high) loop
            if not string_char_is_numeric(Str(CurrentIdx_v)) then
                CurrentIdx_v := Str'high+1;
            else
                AbsoluteVal_v := AbsoluteVal_v * 10 + string_int_from_char(Str(CurrentIdx_v));
                CurrentIdx_v := CurrentIdx_v + 1;
            end if;
        end loop;
        
        -- Return number with correct sign
        if IsNegative_v then
            return -AbsoluteVal_v;
        else
            return AbsoluteVal_v;
        end if;
    end function;
    
end;
