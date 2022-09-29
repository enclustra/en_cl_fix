%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--  Authors: Martin Heimlicher
%--------------------------------------------------------------------------
%
% Write a fix-point number/vector into a file as integer in the unit LSBs. 
%
% The number is left shifted until all fractional bits have become integer
% bits before it is written.
%
% cl_fix_write_int(FILENAME, A, A_FMT)
%
% FILENAME      name of the file to write into
% A             fix-point number to write
% A_FMT         format of A (cl_fix_format)
%
% See also en_cl_fix_format
%
function cl_fix_write_int (filename, a, a_fmt)

cl_fix_constants;

% fraction bits
a = cl_fix_from_real(a, a_fmt, Sat.Warn_s);
a = a*2^a_fmt.FracBits;

fid = fopen (filename, 'wt');
fprintf (fid, '%.0f \n', a);    % avoids writing of exponential format
fclose (fid);
