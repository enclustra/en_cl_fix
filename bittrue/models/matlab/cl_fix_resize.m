% -------------------------------------------------------------------------------------------------
% function r = cl_fix_resize(a, a_fmt, r_fmt, [round], [saturate])
% -------------------------------------------------------------------------------------------------
% MATLAB wrapper for implementation in en_cl_fix_pkg.py.
% -------------------------------------------------------------------------------------------------
function r = cl_fix_resize(varargin)
    r = py.en_cl_fix_pkg.cl_fix_resize(varargin{:});
end
