%--------------------------------------------------------------------------------------------------
%-- Copyright (c) 2021 Enclustra GmbH, Switzerland (info@enclustra.com)
%--------------------------------------------------------------------------------------------------
% Run this script to load constants used widely in cl_fix_* functions.
%
% Note: Loading constants this way is very slow in MATLAB. For faster execution, pass all constants
%       into the functions that use them. As of 2021, no better alternatives exist.
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
