%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--  Authors: Martin Heimlicher
%--------------------------------------------------------------------------
%
% Convert a fix-point format to a string in the form:
% "(<signed>,<intBits>,<fracBits>)"
%
% This function can be very useful together with the en_cl_bittrue library.
%
% STR = cl_fix_string_from_format(FMT)
%
% STR           string representation of FMT
% FMT           format to generate string representation for
%
% See also en_cl_fix_format
%
function str = cl_fix_string_from_format(fmt)

str = '(';
if fmt.Signed 
    str = [str 'true'];
else
    str = [str 'false'];
end
str = [str ',' sprintf('%i',fmt.IntBits)];
str = [str ',' sprintf('%i',fmt.FracBits) ')'];
