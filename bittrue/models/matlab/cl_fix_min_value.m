% -------------------------------------------------------------------------------------------------
% function r = cl_fix_min_value(fmt)
% -------------------------------------------------------------------------------------------------
% MATLAB wrapper for implementation in en_cl_fix_pkg.py.
% -------------------------------------------------------------------------------------------------
function r = cl_fix_min_value(fmt)
    r = py.en_cl_fix_pkg.cl_fix_min_value(fmt);
end
