%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--------------------------------------------------------------------------
%
% Calculate the mean value of two fix-point numbers/vectors.
%
% RESULT = cl_fix_mean(A, A_FMT, B, B_FMT, RESULT_FMT, ROUND, SATURATE)
%
% RESULT        mean value of A and B
% A             fix-point input A
% A_FMT         format of A (cl_fix_format)
% B             fix-point input A
% B_FMT         format of A (cl_fix_format)
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
function result = cl_fix_mean (a, a_fmt, b, b_fmt, result_fmt, round, saturate)

cl_fix_constants

temp_fmt = cl_fix_format (a_fmt.Signed || b_fmt.Signed, max (a_fmt.IntBits, b_fmt.IntBits)+1, max (a_fmt.FracBits, b_fmt.FracBits));
temp = cl_fix_add (a, a_fmt, b, b_fmt, temp_fmt, Round.Trunc_s, Sat.None_s);
result = cl_fix_shift (temp, temp_fmt, -1, result_fmt, round, saturate);
