%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--  Authors: Martin Heimlicher
%--------------------------------------------------------------------------
%
% Get sign bit of a fix-point number/vector.
%
% SIGN = cl_fix_int(A, A_FMT)
%
% SIGN          sign bit of A
% A             fix-point input
% A_FMT         format of A (cl_fix_format)
%
% See also en_cl_fix_format
%
function sign = cl_fix_sign (a, a_fmt)

sign = a < 0;
