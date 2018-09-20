%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--------------------------------------------------------------------------
%
% Conditionally add or subtract two fix-point numbers or vectors.
%
% RESULT = cl_fix_addsub(A, A_FMT, B, B_FMT, ADD, RESULT_FMT, ROUND, SATURATE)
%
% RESULT        result of the addition A + B or subtraction A - B
% A             fix-point input A
% A_FMT         format of A (cl_fix_format)
% B             fix-point input A
% B_FMT         format of A (cl_fix_format)
% ADD           A + B if true, A - B if false
% RESULT_FMT    format of RESULT (cl_fix_format)
% ROUND         rounding mode 
% SATURATE      saturation mode
%
% The script cl_fix_constants must be executed prior to this function.
%
% Allowed rounding modes are (see doxygen VHDL documentation for details):
% - Round.Trunc_s
% - Round.NonSymPos_s
% - Round.NonSymNeg_s
% - Round.SymInf_s
% - Round.SymZero_s
% - Round.ConvEven_s
% - Round.ConvOdd_s
%
% Allowed saturation modes are (see doxygen VHDL documentation for details):
% - Sat.None_s
% - Sat.Warn_s
% - Sat.Sat_s
% - Sat.SatWarn_s
%
% See also en_cl_fix_constants, en_cl_fix_format
%
function result = cl_fix_addsub (a, a_fmt, b, b_fmt, add, result_fmt, round, saturate)

temp_fmt = cl_fix_format (a_fmt.Signed || b_fmt.Signed, max (a_fmt.IntBits, b_fmt.IntBits)+1, max (a_fmt.FracBits, b_fmt.FracBits));
result = cl_fix_resize (a+(-1).^(add==0).*b, temp_fmt, result_fmt, round, saturate);
