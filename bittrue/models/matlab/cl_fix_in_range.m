%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--------------------------------------------------------------------------
%
% Check if a fix-point number/vector can be represented in a given format without
% saturation.
%
% RESULT = cl_fix_in_range(A, A_FMT, RESULT_FMT, ROUND)
%
% RESULT        true if A can be represented in RESULT_FMT without
%               saturation
% A             fix-point number to check
% A_FMT         format of A (cl_fix_format)
% RESULT_FMT    format of RESULT (cl_fix_format)
% ROUND         rounding mode 
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
% See also en_cl_fix_constants, en_cl_fix_format
%
function result = cl_fix_in_range (a, a_fmt, result_fmt, round)

cl_fix_constants

% add rounding constant
if round && a_fmt.FracBits > result_fmt.FracBits
	switch round
	case Round.Trunc_s		% cut off bits
	case Round.NonSymPos_s	% non-symmetric rounding to positive
		a = a + 2^(-result_fmt.FracBits-1);
	case Round.NonSymNeg_s	% non-symmetric rounding to negative
		a = a + 2^(-result_fmt.FracBits-1) - 2^-a_fmt.FracBits;
	case Round.SymInf_s		% symmetric rounding to infinity
		a = a + 2^(-result_fmt.FracBits-1) - 2^-a_fmt.FracBits*(a < 0);
	case Round.SymZero_s	% symmetric rounding to zero
		a = a + 2^(-result_fmt.FracBits-1) - 2^-a_fmt.FracBits*(a >= 0);
	case Round.ConvEven_s	% convergent rounding to even number
		a = a + 2^(-result_fmt.FracBits-1) - 2^-a_fmt.FracBits*mod (floor (a*2^result_fmt.FracBits)+1, 2);
	case Round.ConvOdd_s	% convergent rounding to odd number
		a = a + 2^(-result_fmt.FracBits-1) - 2^-a_fmt.FracBits*mod (floor (a*2^result_fmt.FracBits), 2);
	otherwise
		error ('Illegal value for "round"!');
	end
end

% cut off extra fractional bits
a = floor (a.*2^result_fmt.FracBits).*2^-result_fmt.FracBits;

% check range
result = ones(size(a));
if result_fmt.Signed % signed
    result(a >= 2^result_fmt.IntBits) = 0;
    result(a < -2^result_fmt.IntBits) = 0;
else % unsigned
    result(a >= 2^result_fmt.IntBits) = 0;
    result(a < 0) = 0;
end
