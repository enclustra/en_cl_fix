% -------------------------------------------------------------------------------------------------
% function fmt = cl_fix_shift_fmt(a_fmt, min_shift, [max_shift])
% -------------------------------------------------------------------------------------------------
% MATLAB wrapper for implementation in en_cl_fix_pkg.py.
% -------------------------------------------------------------------------------------------------
function fmt = cl_fix_shift_fmt(varargin)
    v = varargin;
    for i = 2:length(v)
        v{i} = int32(v{i});
    end
    fmt = py.en_cl_fix_pkg.cl_fix_shift_fmt(v{:});
end
