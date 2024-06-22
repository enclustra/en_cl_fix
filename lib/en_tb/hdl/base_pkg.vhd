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
-- Basic functionality for simulation only.
--
---------------------------------------------------------------------------------------------------
-- Notes on array types:
--
-- All ieee.numeric_std and ieee.numeric_bit types are referenced explicitly to avoid ambiguity.
-- 
-- Until VHDL-2019 is supported, it seems like it is best to copy-paste everything for each data
-- type. VHDL-2008 struggles with generic types that are array types and any workarounds seem to be
-- *extremely* cumbersome (significant effort has been invested into trying to make it work).
--
-- The most fundamental problem is that it is impossible to constrain the subtype dimension for a
-- generic unconstrained type: variable ReturnValue_v : Array_t(N-1 downto 0)(<cannot constrain>).
-- This doesn't matter in some cases (e.g. Numel, Unflatten), but seems to be impossible to work
-- around in many cases (e.g. Flatten) using VHDL-2008.
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Libraries
---------------------------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;

library vunit_lib;
    context vunit_lib.vunit_context;

---------------------------------------------------------------------------------------------------
-- Package
---------------------------------------------------------------------------------------------------
package base_pkg is
    
    -----------------------------------------------------------------------------------------------
    -- Misc Types
    -----------------------------------------------------------------------------------------------
    type Signedness_t is (Unsigned_s, Signed_s);
    
    -----------------------------------------------------------------------------------------------
    -- Unconstrained Array Types
    -----------------------------------------------------------------------------------------------
    type SlvArray_t is array(integer range<>) of std_logic_vector;
    type SulvArray_t is array(integer range<>) of std_ulogic_vector;
    type UnsignedArray_t is array(integer range<>) of ieee.numeric_std.unsigned;
    type SignedArray_t is array(integer range<>) of ieee.numeric_std.signed;
    type BitVectorArray_t is array(integer range<>) of bit_vector;
    type UnsignedBitArray_t is array(integer range<>) of ieee.numeric_bit.unsigned;
    type SignedBitArray_t is array(integer range<>) of ieee.numeric_bit.signed;
    
    -----------------------------------------------------------------------------------------------
    -- Unconstrained Array Subprograms
    -----------------------------------------------------------------------------------------------
    
    -- Numel        => Returns total number of elements.
    -- Flatten      => Flattens array to long vector.
    -- Unflatten    => (Procedure) Unflattens long vector to array. Called as: Unflatten(X, Y).
    -- Unflatten    => (Function) Often more convenient than procedure: Y := Unflatten(X, Y).
    
    function Numel(X : SlvArray_t)         return natural;
    function Numel(X : SulvArray_t)        return natural;
    function Numel(X : UnsignedArray_t)    return natural;
    function Numel(X : SignedArray_t)      return natural;
    function Numel(X : BitVectorArray_t)   return natural;
    function Numel(X : UnsignedBitArray_t) return natural;
    function Numel(X : SignedBitArray_t)   return natural;
    
    function Flatten(X : SlvArray_t)         return std_logic_vector;
    function Flatten(X : SulvArray_t)        return std_ulogic_vector;
    function Flatten(X : UnsignedArray_t)    return ieee.numeric_std.unsigned;
    function Flatten(X : SignedArray_t)      return ieee.numeric_std.signed;
    function Flatten(X : BitVectorArray_t)   return bit_vector;
    function Flatten(X : UnsignedBitArray_t) return ieee.numeric_bit.unsigned;
    function Flatten(X : SignedBitArray_t)   return ieee.numeric_bit.signed;
    
    procedure Unflatten(X : std_logic_vector;          Y : out SlvArray_t);
    procedure Unflatten(X : std_ulogic_vector;         Y : out SulvArray_t);
    procedure Unflatten(X : ieee.numeric_std.unsigned; Y : out UnsignedArray_t);
    procedure Unflatten(X : ieee.numeric_std.signed;   Y : out SignedArray_t);
    procedure Unflatten(X : bit_vector;                Y : out BitVectorArray_t);
    procedure Unflatten(X : ieee.numeric_bit.unsigned; Y : out UnsignedBitArray_t);
    procedure Unflatten(X : ieee.numeric_bit.signed;   Y : out SignedBitArray_t);
    
    function Unflatten(X : std_logic_vector; shape : SlvArray_t)                  return SlvArray_t;
    function Unflatten(X : std_ulogic_vector; shape : SulvArray_t)                return SulvArray_t;
    function Unflatten(X : ieee.numeric_std.unsigned; shape : UnsignedArray_t)    return UnsignedArray_t;
    function Unflatten(X : ieee.numeric_std.signed; shape : SignedArray_t)        return SignedArray_t;
    function Unflatten(X : bit_vector; shape : BitVectorArray_t)                  return BitVectorArray_t;
    function Unflatten(X : ieee.numeric_bit.unsigned; shape : UnsignedBitArray_t) return UnsignedBitArray_t;
    function Unflatten(X : ieee.numeric_bit.signed; shape : SignedBitArray_t)     return SignedBitArray_t;
    
    -----------------------------------------------------------------------------------------------
    -- Array Check Functions
    -----------------------------------------------------------------------------------------------
    
    -- It is not clear why these are not included in VUnit.
    
    -- With checker...
    procedure check_equal(checker : checker_t; got, expected : bit_vector; msg : string := "");
    procedure check_equal(checker : checker_t; got, expected : ieee.numeric_bit.unsigned; msg : string := "");
    procedure check_equal(checker : checker_t; got, expected : ieee.numeric_bit.signed; msg : string := "");
    
    -- Without checker...
    procedure check_equal(got, expected : bit_vector; msg : string := "");
    procedure check_equal(got, expected : ieee.numeric_bit.unsigned; msg : string := "");
    procedure check_equal(got, expected : ieee.numeric_bit.signed; msg : string := "");
    
    -----------------------------------------------------------------------------------------------
    -- Unconstrained Array Check Functions
    -----------------------------------------------------------------------------------------------
    
    -- With checker...
    procedure check_equal(checker : checker_t; got, expected : SlvArray_t; msg : string := "");
    procedure check_equal(checker : checker_t; got, expected : SulvArray_t; msg : string := "");
    procedure check_equal(checker : checker_t; got, expected : UnsignedArray_t; msg : string := "");
    procedure check_equal(checker : checker_t; got, expected : SignedArray_t; msg : string := "");
    procedure check_equal(checker : checker_t; got, expected : BitVectorArray_t; msg : string := "");
    procedure check_equal(checker : checker_t; got, expected : UnsignedBitArray_t; msg : string := "");
    procedure check_equal(checker : checker_t; got, expected : SignedBitArray_t; msg : string := "");
    
    -- Without checker...
    procedure check_equal(got, expected : SlvArray_t; msg : string := "");
    procedure check_equal(got, expected : SulvArray_t; msg : string := "");
    procedure check_equal(got, expected : UnsignedArray_t; msg : string := "");
    procedure check_equal(got, expected : SignedArray_t; msg : string := "");
    procedure check_equal(got, expected : BitVectorArray_t; msg : string := "");
    procedure check_equal(got, expected : UnsignedBitArray_t; msg : string := "");
    procedure check_equal(got, expected : SignedBitArray_t; msg : string := "");
    
end package;

---------------------------------------------------------------------------------------------------
-- Package Body
---------------------------------------------------------------------------------------------------
package body base_pkg is
    
    -----------------------------------------------------------------------------------------------
    -- Unconstrained Array Subprograms
    -----------------------------------------------------------------------------------------------
    
    -- Numel
    function Numel(X : SlvArray_t) return natural is
    begin
        return X'length * X'element'length;
    end function;
    
    function Numel(X : SulvArray_t) return natural is
    begin
        return X'length * X'element'length;
    end function;
    
    function Numel(X : UnsignedArray_t) return natural is
    begin
        return X'length * X'element'length;
    end function;
    
    function Numel(X : SignedArray_t) return natural is
    begin
        return X'length * X'element'length;
    end function;
    
    function Numel(X : BitVectorArray_t) return natural is
    begin
        return X'length * X'element'length;
    end function;
    
    function Numel(X : UnsignedBitArray_t) return natural is
    begin
        return X'length * X'element'length;
    end function;
    
    function Numel(X : SignedBitArray_t) return natural is
    begin
        return X'length * X'element'length;
    end function;
    
    -- Flatten
    function Flatten(X : SlvArray_t) return std_logic_vector is
        constant Nbits_c    : natural := X'element'length;
        variable v  : std_logic_vector(Numel(X)-1 downto 0);
    begin
        for i in X'range loop
            v((i+1)*Nbits_c-1 downto i*Nbits_c) := X(i);
        end loop;
        return v;
    end function;
    
    function Flatten(X : SulvArray_t) return std_ulogic_vector is
        constant Nbits_c    : natural := X'element'length;
        variable v  : std_ulogic_vector(Numel(X)-1 downto 0);
    begin
        for i in X'range loop
            v((i+1)*Nbits_c-1 downto i*Nbits_c) := X(i);
        end loop;
        return v;
    end function;
    
    function Flatten(X : UnsignedArray_t) return ieee.numeric_std.unsigned is
        constant Nbits_c    : natural := X'element'length;
        variable v  : ieee.numeric_std.unsigned(Numel(X)-1 downto 0);
    begin
        for i in X'range loop
            v((i+1)*Nbits_c-1 downto i*Nbits_c) := X(i);
        end loop;
        return v;
    end function;
    
    function Flatten(X : SignedArray_t) return ieee.numeric_std.signed is
        constant Nbits_c    : natural := X'element'length;
        variable v  : ieee.numeric_std.signed(Numel(X)-1 downto 0);
    begin
        for i in X'range loop
            v((i+1)*Nbits_c-1 downto i*Nbits_c) := X(i);
        end loop;
        return v;
    end function;
    
    function Flatten(X : BitVectorArray_t) return bit_vector is
        constant Nbits_c    : natural := X'element'length;
        variable v  : bit_vector(Numel(X)-1 downto 0);
    begin
        for i in X'range loop
            v((i+1)*Nbits_c-1 downto i*Nbits_c) := X(i);
        end loop;
        return v;
    end function;
    
    function Flatten(X : UnsignedBitArray_t) return ieee.numeric_bit.unsigned is
        constant Nbits_c    : natural := X'element'length;
        variable v  : ieee.numeric_bit.unsigned(Numel(X)-1 downto 0);
    begin
        for i in X'range loop
            v((i+1)*Nbits_c-1 downto i*Nbits_c) := X(i);
        end loop;
        return v;
    end function;
    
    function Flatten(X : SignedBitArray_t) return ieee.numeric_bit.signed is
        constant Nbits_c    : natural := X'element'length;
        variable v  : ieee.numeric_bit.signed(Numel(X)-1 downto 0);
    begin
        for i in X'range loop
            v((i+1)*Nbits_c-1 downto i*Nbits_c) := X(i);
        end loop;
        return v;
    end function;
    
    -- Unflatten (procedure)
    procedure Unflatten(X : std_logic_vector; Y : out SlvArray_t) is
        constant Nbits_c    : natural := Y'element'length;
        constant X_c        : std_logic_vector(X'length-1 downto 0) := X; -- Force downto 0.
    begin
        for i in Y'range loop
            Y(i) := X_c((i+1)*Nbits_c-1 downto i*Nbits_c);
        end loop;
    end procedure;
    
    procedure Unflatten(X : std_ulogic_vector; Y : out SulvArray_t) is
        constant Nbits_c    : natural := Y'element'length;
        constant X_c        : std_ulogic_vector(X'length-1 downto 0) := X; -- Force downto 0.
    begin
        for i in Y'range loop
            Y(i) := X_c((i+1)*Nbits_c-1 downto i*Nbits_c);
        end loop;
    end procedure;
    
    procedure Unflatten(X : ieee.numeric_std.unsigned; Y : out UnsignedArray_t) is
        constant Nbits_c    : natural := Y'element'length;
        constant X_c        : ieee.numeric_std.unsigned(X'length-1 downto 0) := X; -- Force downto 0.
    begin
        for i in Y'range loop
            Y(i) := X_c((i+1)*Nbits_c-1 downto i*Nbits_c);
        end loop;
    end procedure;
    
    procedure Unflatten(X : ieee.numeric_std.signed; Y : out SignedArray_t) is
        constant Nbits_c    : natural := Y'element'length;
        constant X_c        : ieee.numeric_std.signed(X'length-1 downto 0) := X; -- Force downto 0.
    begin
        for i in Y'range loop
            Y(i) := X_c((i+1)*Nbits_c-1 downto i*Nbits_c);
        end loop;
    end procedure;
    
    procedure Unflatten(X : bit_vector; Y : out BitVectorArray_t) is
        constant Nbits_c    : natural := Y'element'length;
        constant X_c        : bit_vector(X'length-1 downto 0) := X; -- Force downto 0.
    begin
        for i in Y'range loop
            Y(i) := X_c((i+1)*Nbits_c-1 downto i*Nbits_c);
        end loop;
    end procedure;
    
    procedure Unflatten(X : ieee.numeric_bit.unsigned; Y : out UnsignedBitArray_t) is
        constant Nbits_c    : natural := Y'element'length;
        constant X_c        : ieee.numeric_bit.unsigned(X'length-1 downto 0) := X; -- Force downto 0.
    begin
        for i in Y'range loop
            Y(i) := X_c((i+1)*Nbits_c-1 downto i*Nbits_c);
        end loop;
    end procedure;
    
    procedure Unflatten(X : ieee.numeric_bit.signed; Y : out SignedBitArray_t) is
        constant Nbits_c    : natural := Y'element'length;
        constant X_c        : ieee.numeric_bit.signed(X'length-1 downto 0) := X; -- Force downto 0.
    begin
        for i in Y'range loop
            Y(i) := X_c((i+1)*Nbits_c-1 downto i*Nbits_c);
        end loop;
    end procedure;
    
    -- Unflatten (function)
    function Unflatten(X : std_logic_vector; shape : SlvArray_t) return SlvArray_t is
        variable v  : shape'subtype;
    begin
        Unflatten(X, v);
        return v;
    end function;
    
    function Unflatten(X : std_ulogic_vector; shape : SulvArray_t) return SulvArray_t is
        variable v  : shape'subtype;
    begin
        Unflatten(X, v);
        return v;
    end function;
    
    function Unflatten(X : ieee.numeric_std.unsigned; shape : UnsignedArray_t) return UnsignedArray_t is
        variable v  : shape'subtype;
    begin
        Unflatten(X, v);
        return v;
    end function;
    
    function Unflatten(X : ieee.numeric_std.signed; shape : SignedArray_t) return SignedArray_t is
        variable v  : shape'subtype;
    begin
        Unflatten(X, v);
        return v;
    end function;
    
    function Unflatten(X : bit_vector; shape : BitVectorArray_t) return BitVectorArray_t is
        variable v  : shape'subtype;
    begin
        Unflatten(X, v);
        return v;
    end function;
    
    function Unflatten(X : ieee.numeric_bit.unsigned; shape : UnsignedBitArray_t) return UnsignedBitArray_t is
        variable v  : shape'subtype;
    begin
        Unflatten(X, v);
        return v;
    end function;
    
    function Unflatten(X : ieee.numeric_bit.signed; shape : SignedBitArray_t) return SignedBitArray_t is
        variable v  : shape'subtype;
    begin
        Unflatten(X, v);
        return v;
    end function;
    
    -----------------------------------------------------------------------------------------------
    -- Array Check Functions
    -----------------------------------------------------------------------------------------------
    
    -- With checker...
    procedure check_equal(checker : checker_t; got, expected : bit_vector; msg : string := "") is
    begin
        check_equal(checker, to_std_logic_vector(got), to_std_logic_vector(expected), msg);
    end procedure;
    
    procedure check_equal(checker : checker_t; got, expected : ieee.numeric_bit.unsigned; msg : string := "") is
    begin
        check_equal(checker, bit_vector(got), bit_vector(expected), msg);
    end procedure;
    
    procedure check_equal(checker : checker_t; got, expected : ieee.numeric_bit.signed; msg : string := "") is
    begin
        check_equal(checker, bit_vector(got), bit_vector(expected), msg);
    end procedure;
    
    -- Without checker...
    procedure check_equal(got, expected : bit_vector; msg : string := "") is
    begin
        check_equal(to_std_logic_vector(got), to_std_logic_vector(expected), msg);
    end procedure;
    
    procedure check_equal(got, expected : ieee.numeric_bit.unsigned; msg : string := "") is
    begin
        check_equal(bit_vector(got), bit_vector(expected), msg);
    end procedure;
    
    procedure check_equal(got, expected : ieee.numeric_bit.signed; msg : string := "") is
    begin
        check_equal(bit_vector(got), bit_vector(expected), msg);
    end procedure;
    
    -----------------------------------------------------------------------------------------------
    -- Unconstrained Array Check Functions
    -----------------------------------------------------------------------------------------------
    
    -- With checker...
    procedure check_equal(checker : checker_t; got, expected : SlvArray_t; msg : string := "") is
    begin
        check_equal(checker, got'length, expected'length, msg & " Length mismatch.");
        for i in 0 to expected'length-1 loop
            check_equal(checker, got(i), expected(i), msg & " Data mismatch at index " & to_string(i) & ".");
        end loop;
    end procedure;
    
    procedure check_equal(checker : checker_t; got, expected : SulvArray_t; msg : string := "") is
    begin
        check_equal(checker, got'length, expected'length, msg & " Length mismatch.");
        for i in 0 to expected'length-1 loop
            check_equal(checker, got(i), expected(i), msg & " Data mismatch at index " & to_string(i) & ".");
        end loop;
    end procedure;
    
    procedure check_equal(checker : checker_t; got, expected : UnsignedArray_t; msg : string := "") is
    begin
        check_equal(checker, got'length, expected'length, msg & " Length mismatch.");
        for i in 0 to expected'length-1 loop
            check_equal(checker, got(i), expected(i), msg & " Data mismatch at index " & to_string(i) & ".");
        end loop;
    end procedure;
    
    procedure check_equal(checker : checker_t; got, expected : SignedArray_t; msg : string := "") is
    begin
        check_equal(checker, got'length, expected'length, msg & " Length mismatch.");
        for i in 0 to expected'length-1 loop
            check_equal(checker, got(i), expected(i), msg & " Data mismatch at index " & to_string(i) & ".");
        end loop;
    end procedure;
    
    procedure check_equal(checker : checker_t; got, expected : BitVectorArray_t; msg : string := "") is
    begin
        check_equal(checker, got'length, expected'length, msg & " Length mismatch.");
        for i in 0 to expected'length-1 loop
            check_equal(checker, got(i), expected(i), msg & " Data mismatch at index " & to_string(i) & ".");
        end loop;
    end procedure;
    
    procedure check_equal(checker : checker_t; got, expected : UnsignedBitArray_t; msg : string := "") is
    begin
        check_equal(checker, got'length, expected'length, msg & " Length mismatch.");
        for i in 0 to expected'length-1 loop
            check_equal(checker, got(i), expected(i), msg & " Data mismatch at index " & to_string(i) & ".");
        end loop;
    end procedure;
    
    procedure check_equal(checker : checker_t; got, expected : SignedBitArray_t; msg : string := "") is
    begin
        check_equal(checker, got'length, expected'length, msg & " Length mismatch.");
        for i in 0 to expected'length-1 loop
            check_equal(checker, got(i), expected(i), msg & " Data mismatch at index " & to_string(i) & ".");
        end loop;
    end procedure;
    
    -- Without checker...
    procedure check_equal(got, expected : SlvArray_t; msg : string := "") is
    begin
        check_equal(got'length, expected'length, msg & " Length mismatch.");
        for i in 0 to expected'length-1 loop
            check_equal(got(i), expected(i), msg & " Data mismatch at index " & to_string(i) & ".");
        end loop;
    end procedure;
    
    procedure check_equal(got, expected : SulvArray_t; msg : string := "") is
    begin
        check_equal(got'length, expected'length, msg & " Length mismatch.");
        for i in 0 to expected'length-1 loop
            check_equal(got(i), expected(i), msg & " Data mismatch at index " & to_string(i) & ".");
        end loop;
    end procedure;
    
    procedure check_equal(got, expected : UnsignedArray_t; msg : string := "") is
    begin
        check_equal(got'length, expected'length, msg & " Length mismatch.");
        for i in 0 to expected'length-1 loop
            check_equal(got(i), expected(i), msg & " Data mismatch at index " & to_string(i) & ".");
        end loop;
    end procedure;
    
    procedure check_equal(got, expected : SignedArray_t; msg : string := "") is
    begin
        check_equal(got'length, expected'length, msg & " Length mismatch.");
        for i in 0 to expected'length-1 loop
            check_equal(got(i), expected(i), msg & " Data mismatch at index " & to_string(i) & ".");
        end loop;
    end procedure;
    
    procedure check_equal(got, expected : BitVectorArray_t; msg : string := "") is
    begin
        check_equal(got'length, expected'length, msg & " Length mismatch.");
        for i in 0 to expected'length-1 loop
            check_equal(got(i), expected(i), msg & " Data mismatch at index " & to_string(i) & ".");
        end loop;
    end procedure;
    
    procedure check_equal(got, expected : UnsignedBitArray_t; msg : string := "") is
    begin
        check_equal(got'length, expected'length, msg & " Length mismatch.");
        for i in 0 to expected'length-1 loop
            check_equal(got(i), expected(i), msg & " Data mismatch at index " & to_string(i) & ".");
        end loop;
    end procedure;
    
    procedure check_equal(got, expected : SignedBitArray_t; msg : string := "") is
    begin
        check_equal(got'length, expected'length, msg & " Length mismatch.");
        for i in 0 to expected'length-1 loop
            check_equal(got(i), expected(i), msg & " Data mismatch at index " & to_string(i) & ".");
        end loop;
    end procedure;
    
end package body;
