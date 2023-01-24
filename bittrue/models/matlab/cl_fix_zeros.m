% -------------------------------------------------------------------------------------------------
% function r = cl_fix_zeros(shape, fmt)
% -------------------------------------------------------------------------------------------------
% MATLAB wrapper for implementation in en_cl_fix_pkg.py.
% -------------------------------------------------------------------------------------------------
function r = cl_fix_zeros(shape, fmt)
    r = py.en_cl_fix_pkg.cl_fix_zeros(int32(shape), fmt);
end
