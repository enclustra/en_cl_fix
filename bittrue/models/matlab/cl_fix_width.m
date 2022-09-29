%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--  Authors: Martin Heimlicher
%--------------------------------------------------------------------------
%
% Calculate the number of bits required for a number of the given format.
%
% BITS = cl_fix_width(FMT)
%
% BITS          number of bits required for a number of the format FMT
% FMT           format to get the number of bits for
%
% See also en_cl_fix_format
%
function bits = cl_fix_width (fmt)

if (fmt.IntBits+fmt.FracBits) < 1
	error ('cl_fix_width : "IntBits"+"FracBits" must be at least 1!');
end
if (fmt.IntBits+fmt.FracBits) > 52
	error ('cl_fix_width : "IntBits"+"FracBits" must be at most 52!');
end

bits = fmt.Signed + fmt.IntBits + fmt.FracBits;
