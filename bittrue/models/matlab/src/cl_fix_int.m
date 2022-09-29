%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--------------------------------------------------------------------------
%
% Get integer bits of a fix-point number/vector.
%
% RESULT = cl_fix_int(A, A_FMT)
%
% RESULT        integer bits of A 
% A             fix-point input
% A_FMT         format of A (cl_fix_format)
%
% See also en_cl_fix_format
%
function int = cl_fix_int (a, a_fmt)

int = mod (floor (a), 2^a_fmt.IntBits);
