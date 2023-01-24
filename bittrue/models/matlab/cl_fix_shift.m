% -------------------------------------------------------------------------------------------------
% function r = cl_fix_shift(a, a_fmt, shift, r_fmt, [round], [saturate])
% -------------------------------------------------------------------------------------------------
% MATLAB wrapper for implementation in en_cl_fix_pkg.py.
% -------------------------------------------------------------------------------------------------
function r = cl_fix_shift(varargin)
    r = py.en_cl_fix_pkg.cl_fix_shift(varargin{:});
end
