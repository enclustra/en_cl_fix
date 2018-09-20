%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--  Authors: Martin Heimlicher
%--------------------------------------------------------------------------
%
% Calculate the absolute value of a fix-point number/vector.
% Simple implementation (optimized for performance and resource usage
% within the FPGA).
%
% NOTE: If a is negative, this function leads to an error of one LSB.
%
% RESULT = cl_fix_sabs(A, A_FMT, RESULT_FMT, ROUND, SATURATE)
%
% RESULT        absolute value of A
% A             fix-point number to get the absolute value from
% A_FMT         format of A (cl_fix_format)
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
function result = cl_fix_sabs (a, a_fmt, result_fmt, round, saturate)

cl_fix_constants

if a_fmt.Signed % signed
	temp_fmt = cl_fix_format (true, a_fmt.IntBits, max (a_fmt.FracBits, result_fmt.FracBits));
	temp = cl_fix_resize (a, a_fmt, temp_fmt, Round.Trunc_s, Sat.None_s);
	temp = -(temp<0)*2^-temp_fmt.FracBits + abs (temp);
	result = cl_fix_resize (temp, temp_fmt, result_fmt, round, saturate);
else % unsigned
	result = cl_fix_resize (a, a_fmt, result_fmt, round, saturate);
end
