% -------------------------------------------------------------------------------------------------
% function r = cl_fix_from_integer(a, a_fmt)
% -------------------------------------------------------------------------------------------------
% MATLAB wrapper for implementation in en_cl_fix_pkg.py.
% -------------------------------------------------------------------------------------------------
function r = cl_fix_from_integer(a, a_fmt)
    r = py.en_cl_fix_pkg.cl_fix_from_integer(a, a_fmt);
    r = py2mat(r);
end
