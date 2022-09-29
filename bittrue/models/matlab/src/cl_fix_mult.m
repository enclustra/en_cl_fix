%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--------------------------------------------------------------------------
%
% Multiply two fix point numbers/vectors.
%
% RESULT = cl_fix_mult(A, A_FMT, B, B_FMT, RESULT_FMT, ROUND, SATURATE)
%
% RESULT        result of the multiplication A*B
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
function result = cl_fix_mult (a, a_fmt, b, b_fmt, result_fmt, round, saturate)

signed = a_fmt.Signed || b_fmt.Signed;
temp_fmt = cl_fix_format (signed, a_fmt.IntBits+b_fmt.IntBits+signed, a_fmt.FracBits+b_fmt.FracBits);
result = cl_fix_resize (a.*b, temp_fmt, result_fmt, round, saturate);
