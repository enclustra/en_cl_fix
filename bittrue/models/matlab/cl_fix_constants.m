%--------------------------------------------------------------------------------------------------
% Run this script to load constants used widely in cl_fix_* functions.
%
% Note: Loading constants this way is very slow in MATLAB. For faster execution, pass all constants
%       into the functions that use them. As of 2021, no better alternatives exist.
%--------------------------------------------------------------------------------------------------

%--------------------------------------------------------------------------------------------------
% Copyright (c) 2024 Enclustra GmbH, Switzerland (info@enclustra.com)
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy of this software
% and associated documentation files (the "Software"), to deal in the Software without
% restriction, including without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
% Software is furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all copies or
% substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
% BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
% NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
%--------------------------------------------------------------------------------------------------

% Saturation constants
Sat.None_s =    py.en_cl_fix_pkg.FixSaturate(0);
Sat.Warn_s =    py.en_cl_fix_pkg.FixSaturate(1);
Sat.Sat_s =     py.en_cl_fix_pkg.FixSaturate(2);
Sat.SatWarn_s = py.en_cl_fix_pkg.FixSaturate(3);

% Rounding constants
Round.Trunc_s =     py.en_cl_fix_pkg.FixRound(0);
Round.NonSymPos_s = py.en_cl_fix_pkg.FixRound(1);
Round.NonSymNeg_s = py.en_cl_fix_pkg.FixRound(2);
Round.SymInf_s =    py.en_cl_fix_pkg.FixRound(3);
Round.SymZero_s =   py.en_cl_fix_pkg.FixRound(4);
Round.ConvEven_s =  py.en_cl_fix_pkg.FixRound(5);
Round.ConvOdd_s =   py.en_cl_fix_pkg.FixRound(6);
