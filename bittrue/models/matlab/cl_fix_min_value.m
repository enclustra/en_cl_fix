%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--------------------------------------------------------------------------
%
% Get the minimum value representable with a given format.
%
% RESULT = cl_fix_min_value(FMT)
%
% RESULT        minimum value representable in FMT
% FMT           format to get the minimum value for
%
% See also en_cl_fix_format
%
function result = cl_fix_min_value (fmt)

if fmt.Signed
	result = -2^fmt.IntBits;
else
	result = 0;
end
