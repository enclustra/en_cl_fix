% -------------------------------------------------------------------------------------------------
% function r = cl_fix_addsub(a, a_fmt, b, b_fmt, add, r_fmt, [round], [saturate])
% -------------------------------------------------------------------------------------------------
% MATLAB wrapper for implementation in en_cl_fix_pkg.py.
% -------------------------------------------------------------------------------------------------
function r = cl_fix_addsub(varargin)
    r = py.en_cl_fix_pkg.cl_fix_addsub(varargin{:});
    r = py2mat(r);
end
