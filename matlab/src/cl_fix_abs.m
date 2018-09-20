%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--  Authors: Martin Heimlicher
%--------------------------------------------------------------------------
%
% Calculate the absolute value of a fix-point number or vector.
%
% RESULT = cl_fix_abs(A, A_FMT, RESULT_FMT, ROUND, SATURATE)
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
function result = cl_fix_abs (a, a_fmt, result_fmt, round, saturate)

if a_fmt.Signed % signed
	temp_fmt = cl_fix_format (a_fmt.Signed, a_fmt.IntBits+1, a_fmt.FracBits);
	result = cl_fix_resize (abs (a), temp_fmt, result_fmt, round, saturate);
else % unsigned
	result = cl_fix_resize (a, a_fmt, result_fmt, round, saturate);
end
