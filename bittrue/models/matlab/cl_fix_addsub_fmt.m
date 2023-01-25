% -------------------------------------------------------------------------------------------------
% function fmt = cl_fix_addsub_fmt(a_fmt, b_fmt)
% -------------------------------------------------------------------------------------------------
% MATLAB wrapper for implementation in en_cl_fix_pkg.py.
% -------------------------------------------------------------------------------------------------
function fmt = cl_fix_addsub_fmt(a_fmt, b_fmt)
    fmt = py.en_cl_fix_pkg.cl_fix_addsub_fmt(a_fmt, b_fmt);
end
