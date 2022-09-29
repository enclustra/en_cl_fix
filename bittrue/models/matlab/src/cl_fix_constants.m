%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--------------------------------------------------------------------------
%
% This script must be executed prior to any cl_fix_... functions
%

% saturation constants
Sat.None_s = 0;
Sat.Warn_s = 1;
Sat.Sat_s = 2;
Sat.SatWarn_s = 3;

% rounding constants
Round.Trunc_s = 0;
Round.NonSymPos_s = 1;
Round.NonSymNeg_s = 2;
Round.SymInf_s = 3;
Round.SymZero_s = 4;
Round.ConvEven_s = 5;
Round.ConvOdd_s = 6;
