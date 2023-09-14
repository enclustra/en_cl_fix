% -------------------------------------------------------------------------------------------------
% function r = cl_fix_round(a, a_fmt, r_fmt, [round])
% -------------------------------------------------------------------------------------------------
% MATLAB wrapper for implementation in en_cl_fix_pkg.py.
% -------------------------------------------------------------------------------------------------
function r = cl_fix_round(varargin)
    r = py.en_cl_fix_pkg.cl_fix_round(varargin{:});
    r = py2mat(r);
end
