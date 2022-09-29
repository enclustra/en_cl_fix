%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--  Authors: Martin Heimlicher
%--------------------------------------------------------------------------
%
% Set a given bit within a fix-point number/vector (LSB based index).
%
% RESULT = cl_fix_set_lsb(A, A_FMT, INDEX, VALUE)
%
% RESULT        A with the given bit set to VALUE
% A             fix-point input A
% A_FMT         format of A (cl_fix_format)
% INDEX         index of the bit to set (LSB based)
% VALUE         value to set the bit to (1 or 0)
%
% See also en_cl_fix_format
%
function result = cl_fix_set_lsb (a, a_fmt, index, value)

if index < 0
	error ('cl_fix_set_lsb : "index" must be positive or zero!');
end
if index >= cl_fix_width (a_fmt)
	error ('cl_fix_set_lsb : "index" too high!');
end

if a_fmt.Signed % signed
	if index == a_fmt.IntBits+a_fmt.FracBits
		current = a < 0;
		result = ((value-0.5)-(current-0.5)).*-2^(a_fmt.IntBits)+a;
	else
		current = mod (a*2^(a_fmt.FracBits-index-1), 1) >= 0.5;
		result = ((value-0.5)-(current-0.5)).*2^(index-a_fmt.FracBits)+a;
	end
else % unsigned
	current = mod (a*2^(a_fmt.FracBits-index-1), 1) >= 0.5;
	result = ((value-0.5)-(current-0.5)).*2^(index-a_fmt.FracBits)+a;
end
