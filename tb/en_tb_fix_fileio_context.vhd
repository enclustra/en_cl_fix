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
-- README:
--
-- Copy-paste this file into your project's tb/ directory and rename "lib" to the correct name.
-- 
-- This is necessary in any cases where there are shared dependencies between a library and the
-- main project compilation lib because:
--   - Libraries specified in contexts must have known fixed names (not work.).
--   - Compiling a dependency into two libraries creates clashes (e.g. type mismatches between the
--     same type defined in the same package, but compiled into different libraries).
---------------------------------------------------------------------------------------------------

context en_tb_fix_fileio_context is
  library lib_en_cl_fix;
  context lib_en_cl_fix.en_tb_fileio_context;
  use lib_en_cl_fix.en_tb_fix_fileio_pkg.all;
  use lib_en_cl_fix.en_cl_fix_pkg.all;
end context;
