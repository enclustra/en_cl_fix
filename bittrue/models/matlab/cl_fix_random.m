% -------------------------------------------------------------------------------------------------
% function r = cl_fix_random(shape, fmt)
% -------------------------------------------------------------------------------------------------
% MATLAB wrapper for implementation in en_cl_fix_pkg.py.
% -------------------------------------------------------------------------------------------------
function r = cl_fix_random(shape, fmt)
    r = py.en_cl_fix_pkg.cl_fix_random(int32(shape), fmt);
    r = py2mat(r);
end
