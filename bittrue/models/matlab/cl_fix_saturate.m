% -------------------------------------------------------------------------------------------------
% function r = cl_fix_saturate(a, a_fmt, r_fmt, [saturate])
% -------------------------------------------------------------------------------------------------
% MATLAB wrapper for implementation in en_cl_fix_pkg.py.
% -------------------------------------------------------------------------------------------------
function r = cl_fix_saturate(varargin)
    r = py.en_cl_fix_pkg.cl_fix_saturate(varargin{:});
    r = py2mat(r);
end
