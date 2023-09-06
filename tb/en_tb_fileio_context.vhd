---------------------------------------------------------------------------------------------------
--  Copyright (c) 2021 Enclustra GmbH, Switzerland (info@enclustra.com)
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

context en_tb_fileio_context is
  library lib_en_cl_fix;
  use lib_en_cl_fix.en_tb_base_pkg.all;
  use lib_en_cl_fix.en_tb_fileio_text_pkg.all;
end context;
