function r = cl_fix_to_integer(a, a_fmt)
    % ---------------------------------------------------------------------------------------------
    % function r = cl_fix_to_integer(a, a_fmt)
    % ---------------------------------------------------------------------------------------------
    % MATLAB wrapper for implementation in en_cl_fix_pkg.py.
    % ---------------------------------------------------------------------------------------------

    % ---------------------------------------------------------------------------------------------
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
    % DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    % FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    % ---------------------------------------------------------------------------------------------

    a = wide.mat2py(a, a_fmt);
    r = py.en_cl_fix_pkg.cl_fix_to_integer(a, a_fmt);
    
    % The returned values are integers. We can handle them as fixed-point, with 0 frac bits.
    r_fmt = cl_fix_format(a_fmt.S, a_fmt.I+a_fmt.F, 0);
    r = wide.py2mat(r, r_fmt);
end
