% -------------------------------------------------------------------------------------------------
% function fmt = cl_fix_round_fmt(a_fmt, r_frac_bits, round)
% -------------------------------------------------------------------------------------------------
% MATLAB wrapper for implementation in en_cl_fix_pkg.py.
% -------------------------------------------------------------------------------------------------
function fmt = cl_fix_round_fmt(a_fmt, r_frac_bits, round)
    fmt = py.en_cl_fix_pkg.cl_fix_round_fmt(a_fmt, int32(r_frac_bits), round);
end
