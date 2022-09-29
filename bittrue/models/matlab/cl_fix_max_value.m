%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--------------------------------------------------------------------------
%
% Get the maximum value representable with a given format.
%
% RESULT = cl_fix_max_value(FMT)
%
% RESULT        maximum value representable in FMT
% FMT           format to get the maximum value for
%
% See also en_cl_fix_format
%
function result = cl_fix_max_value (fmt)

result = 2^fmt.IntBits-2^-fmt.FracBits;
