%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--  Authors: Martin Heimlicher
%--------------------------------------------------------------------------
%
% Left shift of a fix-point number/vector.
%
% RESULT = cl_fix_shift(A, A_FMT, SHIFT, RESULT_FMT, ROUND, SATURATE)
%
% RESULT        result of the shift
% A             fix-point input A
% A_FMT         format of A (cl_fix_format)
% SHIFT         number of bits to shift left (use negative numbers to
%               achieve right shifts)
% RESULT_FMT    format of RESULT (cl_fix_format)
% ROUND         rounding mode 
% SATURATE      saturation mode
%
% The script cl_fix_constants must be executed prior to this function.
%
% Allowed rounding modes are (see doxygen VHDL documentation for details):
% - Round.Trunc_s
% - Round.NonSymPos_s
% - Round.NonSymNeg_s
% - Round.SymInf_s
% - Round.SymZero_s
% - Round.ConvEven_s
% - Round.ConvOdd_s
%
% Allowed saturation modes are (see doxygen VHDL documentation for details):
% - Sat.None_s
% - Sat.Warn_s
% - Sat.Sat_s
% - Sat.SatWarn_s
%
% See also en_cl_fix_constants, en_cl_fix_format
%
function result = cl_fix_shift (a, a_fmt, shift, result_fmt, round, saturate)

temp_fmt = cl_fix_format (a_fmt.Signed, a_fmt.IntBits+shift, a_fmt.FracBits-shift);
result = cl_fix_resize (a*2^shift, temp_fmt, result_fmt, round, saturate);
