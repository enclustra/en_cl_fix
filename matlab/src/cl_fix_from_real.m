%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--------------------------------------------------------------------------
%
% Convert a double number or vector into a fix-point number/vector.
%
% RESULT = cl_fix_from_real(A, RESULT_FMT, SATURATE)
%
% RESULT        fix-point representation of A
% A             double input
% A_FMT         format to convert a into (cl_fix_format)
% SATURATE      saturation mode
%
% The script cl_fix_constants must be executed prior to this function.
%
% Allowed saturation modes are (see doxygen VHDL documentation for details):
% - Sat.None_s
% - Sat.Warn_s
% - Sat.Sat_s
% - Sat.SatWarn_s
%
% See also en_cl_fix_constants, en_cl_fix_format
%
function result = cl_fix_from_real (a, result_fmt, saturate)

cl_fix_constants

% round symmetrically to infinity (same as VHDL)
result = round (a.*2^result_fmt.FracBits).*2^-result_fmt.FracBits;

% saturation warning
if saturate == Sat.Warn_s || saturate == Sat.SatWarn_s
	if result_fmt.Signed % (un)signed to signed
		if any (any (result >= 2^result_fmt.IntBits)) || any (any (result < -2^result_fmt.IntBits))
			warning ('cl_fix_from_real : Saturation warning!');
		end
	else % (un)signed to unsigned
		if any (any (result >= 2^result_fmt.IntBits)) || any (any (result < 0))
			warning ('cl_fix_from_real : Saturation warning!');
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
	error ('cl_fix_from_real : Illegal value for "saturate"!');
end
