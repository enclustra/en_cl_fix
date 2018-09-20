%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--------------------------------------------------------------------------
%
% Assemble a fix-point number from its parts (sign bit, integer bits,
% fractional bits)
%
% RESULT = cl_fix_combine(SIGN, INT, FRAC, RESULT_FMT)
%
% RESULT        assembled fix-point number
% SIGN          sign bit
% INT           integer bits
% FRAC          fractional bits (given as integer number)
% RESULT_FMT    format of RESULT (cl_fix_format)
%
% Example:
% cl_fix_combine(0, 3, 15, cl_fix_format(true, 5, 4))
% --> Result = 3.9375
%
% See also en_cl_fix_format
%
function result = cl_fix_combine (sign, int, frac, result_fmt)

if sign && ~result_fmt.Signed
	error ('cl_fix_combine : sign may not be set for an unsigned format!');
end

result = -sign*2^result_fmt.IntBits + int + frac*2^-result_fmt.FracBits;
