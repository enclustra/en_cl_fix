%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--------------------------------------------------------------------------
%
% Get a given bit within a fix-point number/vector (LSB based index).
%
% BIT = cl_fix_get_lsb(A, A_FMT, INDEX)
%
% BIT           value of the bit requested
% A             fix-point input A
% A_FMT         format of A (cl_fix_format)
% INDEX         index of the bit to get (LSB based)
%
% See also en_cl_fix_format
%
function result = cl_fix_get_lsb (a, a_fmt, index)

if index < 0
	error ('cl_fix_get_lsb : "index" must be positive or zero!');
end
if index >= cl_fix_width (a_fmt)
	error ('cl_fix_get_lsb : "index" too high!');
end

if a_fmt.Signed % signed
	if index == a_fmt.IntBits+a_fmt.FracBits
		result = a < 0;
	else
		result = mod (a*2^(a_fmt.FracBits-index-1), 1) >= 0.5;
	end
else % unsigned
	result = mod (a*2^(a_fmt.FracBits-index-1), 1) >= 0.5;
end
