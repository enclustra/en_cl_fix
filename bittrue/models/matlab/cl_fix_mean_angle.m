%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--------------------------------------------------------------------------
%
% Calculate the mean value of two fix-point modulo numbers/vectors.
% 
% Inputs are interpreted as angles or other numbers with modulo property.
% The calculation is executed with infinite precision and then rounded to
% the format of the result.
%
% RESULT = cl_fix_add(A, A_FMT, B, B_FMT, PRECISE, RESULT_FMT, ROUND, SATURATE)
%
% RESULT        modulo mean value of A and B
% A             fix-point input A
% A_FMT         format of A (cl_fix_format)
% B             fix-point input A
% B_FMT         format of A (cl_fix_format)
% PRECISE       true:   calculation is performed with full precision
%               false:  modulo handling only takes into account the
%                       quadrants of A and B
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
function result = cl_fix_mean_angle (a, a_fmt, b, b_fmt, precise, result_fmt, round, saturate)

cl_fix_constants

if a_fmt.Signed ~= b_fmt.Signed || a_fmt.IntBits ~= b_fmt.IntBits
	error ('cl_fix_mean_angle : Signed and IntBits of "a" and "b" must be identical.');
end
if cl_fix_width (a_fmt) < 2 || cl_fix_width (b_fmt) < 2
	error ('cl_fix_mean_angle : The widths of "a" and "b" must be at least 2 bits each.');
end

% quadrants:  10
%             23

% one point in quadrant 1 and one point in quadrant 2
AMsb0 = cl_fix_get_msb (a, a_fmt, 0);
BMsb0 = cl_fix_get_msb (b, b_fmt, 0);
AMsb1 = cl_fix_get_msb (a, a_fmt, 1);
BMsb1 = cl_fix_get_msb (b, b_fmt, 1);
different_signs = AMsb0 ~= BMsb0;
toggle = different_signs & (AMsb1 ~= BMsb1) & (AMsb0 ~= AMsb1);
a = cl_fix_set_msb (a, a_fmt, 0, bitxor (AMsb0, toggle));

% perform add
temp_fmt = cl_fix_format (a_fmt.Signed || b_fmt.Signed, max (a_fmt.IntBits, b_fmt.IntBits)+1, max (a_fmt.FracBits, b_fmt.FracBits));
temp = cl_fix_add (a, a_fmt, b, b_fmt, temp_fmt, Round.Trunc_s, Sat.None_s);

% one point in quadrant 1 and one point in quadrant 3   or  
%   one point in quadrant 0 and one point in quadrant 2
if precise
	TempMsb0 = cl_fix_get_msb (temp, temp_fmt, 0);
	TempMsb2 = cl_fix_get_msb (temp, temp_fmt, 2);
	toggle = different_signs & (AMsb1 == BMsb1) & (TempMsb2 == AMsb1);
	temp = cl_fix_set_msb (temp, temp_fmt, 0, bitxor (TempMsb0, toggle));
end

% divide by 2
result = cl_fix_shift (temp, temp_fmt, -1, result_fmt, round, saturate);
