%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--------------------------------------------------------------------------
%
% Get fractional bits of a fix-point number or vector.
%
% RESULT = cl_fix_frac(A, A_FMT)
%
% RESULT        fractional bits of A (given as integer number)
% A             fix-point input
% A_FMT         format of A (cl_fix_format)
%
% Example:
% cl_fix_frac(0.375, cl_fix_format(false, 0, 3))
% --> Result = 3
%
% See also en_cl_fix_format
%
function result = cl_fix_frac (a, a_fmt)

result = (a-floor (a))*2^a_fmt.FracBits;
