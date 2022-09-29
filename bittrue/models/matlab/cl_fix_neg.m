%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--------------------------------------------------------------------------
%
% Conditionally calculate the negative value of a fix-point number/vector.
%
% RESULT = cl_fix_neg(A, A_FMT, ENABLE, RESULT_FMT, ROUND, SATURATE)
%
% RESULT        negative value of A or A (depending on ENABLE)
% A             fix-point number to get the absolute value from
% A_FMT         format of A (cl_fix_format)
% ENABLE        true:   RESULT = -A
%               false:  RESULT = A
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
function result = cl_fix_neg (a, a_fmt, enable, result_fmt, round, saturate)

if a_fmt.Signed == 0
	error 'cl_fix_neg : Not allowed on unsigned values.';
end
temp_fmt = cl_fix_format (a_fmt.Signed, a_fmt.IntBits+1, a_fmt.FracBits);
result = cl_fix_resize (a.*(-1).^(enable~=0), temp_fmt, result_fmt, round, saturate);
