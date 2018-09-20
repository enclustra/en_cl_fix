%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--------------------------------------------------------------------------
%
% Fix-point implementation of the MATLAB command fix. This means the value
% is rounded symmetrically towards zero and fractional bits are truncated.
%
% NOTE: Don't use this command yet since it is not yet implemented in VHDL.
%
% RESULT = cl_fix_fix(A, A_FMT)
%
% RESULT        result of the fix operation for A
% A             fix-point input A
% A_FMT         format of A (cl_fix_format)
%
% See also en_cl_fix_format
%
function result = cl_fix_fix (a, a_fmt)

cl_fix_constants
result_fmt = a_fmt;
result_fmt.FracBits = 0;

result = cl_fix_resize (a, a_fmt, result_fmt, Round.SymZero_s, Sat.None_s);
