% -------------------------------------------------------------------------------------------------
% function r = cl_fix_mult(a, a_fmt, b, b_fmt, r_fmt, [round], [saturate])
% -------------------------------------------------------------------------------------------------
% MATLAB wrapper for implementation in en_cl_fix_pkg.py.
% -------------------------------------------------------------------------------------------------
function r = cl_fix_mult(varargin)
    r = py.en_cl_fix_pkg.cl_fix_mult(varargin{:});
end
