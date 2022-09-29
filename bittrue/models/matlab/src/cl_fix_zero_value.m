%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--  Authors: Martin Heimlicher
%--------------------------------------------------------------------------
%
% Get the value closest to zero representable in a given format.
%
% RESULT = cl_fix_zero_value(FMT)
%
% RESULT        value closest to zero representable in FMT
% FMT           format to get the zero value for
%
% See also en_cl_fix_format
%
function result = cl_fix_zero_value (fmt)

result = 0;
