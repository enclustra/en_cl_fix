% -------------------------------------------------------------------------------------------------
% function r = cl_fix_format_to_string(fmt)
% -------------------------------------------------------------------------------------------------
% MATLAB wrapper for implementation in en_cl_fix_pkg.py.
% -------------------------------------------------------------------------------------------------
function r = cl_fix_format_to_string(fmt)
    r = char(py.en_cl_fix_pkg.cl_fix_format_to_string(fmt));
end
