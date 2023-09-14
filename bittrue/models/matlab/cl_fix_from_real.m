% -------------------------------------------------------------------------------------------------
% function r = cl_fix_from_real(a, r_fmt, saturate)
% -------------------------------------------------------------------------------------------------
% MATLAB wrapper for implementation in en_cl_fix_pkg.py.
% -------------------------------------------------------------------------------------------------
function r = cl_fix_from_real(a, r_fmt, saturate)
    r = py.en_cl_fix_pkg.cl_fix_from_real(a, r_fmt, saturate);
    r = py2mat(r);
end