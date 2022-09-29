%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--------------------------------------------------------------------------
%
% Get a given bit within a fix-point number/vector (MSB based index).
%
% BIT = cl_fix_get_msb(A, A_FMT, INDEX)
%
% BIT           value of the bit requested
% A             fix-point input A
% A_FMT         format of A (cl_fix_format)
% INDEX         index of the bit to get (MSB based)
%
% See also en_cl_fix_format
%
function result = cl_fix_get_msb (a, a_fmt, index)

if index < 0
	error ('cl_fix_get_msb : "index" must be positive or zero!');
end
if index >= cl_fix_width (a_fmt)
	error ('cl_fix_get_msb : "index" too high!');
end

if a_fmt.Signed % signed
	if index == 0
		result = a < 0;
	else
		result = mod (a*2^(index-a_fmt.IntBits-1), 1) >= 0.5;
	end
else % unsigned
	result = mod (a*2^(index-a_fmt.IntBits), 1) >= 0.5;
end
