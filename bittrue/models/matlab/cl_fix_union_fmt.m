% -------------------------------------------------------------------------------------------------
% function fmt = cl_fix_union_fmt(a_fmt, [b_fmt])
% -------------------------------------------------------------------------------------------------
% MATLAB wrapper for implementation in en_cl_fix_pkg.py.
% -------------------------------------------------------------------------------------------------
function fmt = cl_fix_union_fmt(varargin)
    fmt = py.en_cl_fix_pkg.cl_fix_union_fmt(varargin{:});
end
