% -------------------------------------------------------------------------------------------------
% function r = cl_fix_in_range(a, a_fmt, r_fmt, [round])
% -------------------------------------------------------------------------------------------------
% MATLAB wrapper for implementation in en_cl_fix_pkg.py.
% -------------------------------------------------------------------------------------------------
function r = cl_fix_in_range(varargin)
    r = py.en_cl_fix_pkg.cl_fix_in_range(varargin{:});
    r = logical(r);
end
