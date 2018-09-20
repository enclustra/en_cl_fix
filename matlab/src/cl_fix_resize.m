%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--------------------------------------------------------------------------
%
% Resize a fix-point number/vector to a different format.
%
% RESULT = cl_fix_resize(A, A_FMT, RESULT_FMT, ROUND, SATURATE)
%
% RESULT        resized version of A
% A             fix-point input
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
function result = cl_fix_resize (a, a_fmt, result_fmt, round, saturate)

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
		error ('cl_fix_resize : Illegal value for "round"!');
	end
end

% cut off extra fractional bits
result = floor (a.*2^result_fmt.FracBits).*2^-result_fmt.FracBits;

% saturation warning
if saturate == Sat.Warn_s || saturate == Sat.SatWarn_s
	if result_fmt.Signed % (un)signed to signed
		if any (any (result >= 2^result_fmt.IntBits)) || any (any (result < -2^result_fmt.IntBits)) 
			warning ('cl_fix_resize : Saturation warning!');
		end
	else % (un)signed to unsigned
		if any (any (result >= 2^result_fmt.IntBits)) || any (any (result < 0)) 
			warning ('cl_fix_resize : Saturation warning!');
		end
    end
end

% saturation
switch saturate
case { Sat.None_s, Sat.Warn_s } % no saturation
	if result_fmt.Signed % signed
		result = mod (result + 2^result_fmt.IntBits, 2^(result_fmt.IntBits+1))-2^result_fmt.IntBits;
	else % unsigned
		result = mod (result, 2^result_fmt.IntBits);
	end
case { Sat.Sat_s, Sat.SatWarn_s } % full saturation
	if result_fmt.Signed % (un)signed to signed
		result (result >= 2^result_fmt.IntBits) = 2^result_fmt.IntBits-2^-result_fmt.FracBits;
		result (result < -2^result_fmt.IntBits) = -2^result_fmt.IntBits;
	else % (un)signed to unsigned
		result (result >= 2^result_fmt.IntBits) = 2^result_fmt.IntBits-2^-result_fmt.FracBits;
		result (result < 0) = 0;
    end
otherwise
	error ('cl_fix_resize : Illegal value for "saturate"!');
end
