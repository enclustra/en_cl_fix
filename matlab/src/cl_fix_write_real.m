%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--  Authors: Martin Heimlicher
%--------------------------------------------------------------------------
%
% Write a fix-point number/vector into a file as double. 
%
% cl_fix_write_real(FILENAME, A, A_FMT)
%
% FILENAME      name of the file to write into
% A             fix-point number to write
% A_FMT         format of A (cl_fix_format)
%
% See also en_cl_fix_format
%
function cl_fix_write_real (filename, a, a_fmt)

%signDigits = a_fmt (1);
signDigits = a_fmt.Signed;
%intDigits = ceil (a_fmt (2)/log2(10));
intDigits = ceil (a_fmt.IntBits/log2(10));
%fracDigits = max (min (a_fmt (3), 8), ceil (a_fmt (3)/log2(10)))
fracDigits = max (min (a_fmt.FracBits, 8), ceil (a_fmt.FracBits/log2(10)));
fid = fopen (filename, 'wt');
fprintf (fid, ['%' num2str(signDigits+intDigits+fracDigits+(fracDigits>0)) '.' num2str(fracDigits) 'f\n'], a);
fclose (fid);
