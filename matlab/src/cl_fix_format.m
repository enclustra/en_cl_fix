%--------------------------------------------------------------------------
%--  Copyright (c) 2014 by Enclustra GmbH, Switzerland
%--  All rights reserved.
%--------------------------------------------------------------------------
%
% Create a cl_fix fix-point format to be used by the cl_fix_... operations.
%
% FORMAT = cl_fix_format(SIGNED, INTBITS, FRACBITS)
%
% FORMAT        format created
% SIGNED        true if the format contains a sign bit, false otherwise
% INTBITS       number of integer bits
% FRACBITS      number of fractional bits
%
function fmt = cl_fix_format (signed, intBits, fracBits)

if (intBits+fracBits) < 1
	error ('cl_fix_format : "intBits"+"fracBits" must be at least 1!');
end
if (intBits+fracBits) > 52
%	error ('cl_fix_format : "intBits"+"fracBits" must be at most 52!');
end

fmt.Signed = signed > 0;
fmt.IntBits = intBits;
fmt.FracBits = fracBits;
