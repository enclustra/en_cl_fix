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
-- Important:
--
-- It is RECOMMENDED (but not REQUIRED) to compile en_tb into a VHDL library named "en_tb".
--
-- When the VHDL library name "en_tb" is used, this VHDL-2008 context can be used. This allows all
-- the required en_tb packages (and only the required ones) to be included via a single use clause.
--
-- In (rare) cases where the "en_tb" name cannot be used, it is recommended to make local copies of
-- this file, with the library name "en_tb" (below) updated to the correct name. An alternative is
-- to just avoid using the context (and instead have multiple use clauses to include the required
-- packages individually).
---------------------------------------------------------------------------------------------------
context fileio_context is
    library en_tb;
    use en_tb.base_pkg.all;
    use en_tb.fileio_text_pkg.all;
end context;
