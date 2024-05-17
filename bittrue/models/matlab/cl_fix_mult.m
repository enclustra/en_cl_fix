function r = cl_fix_mult(varargin)
    % ---------------------------------------------------------------------------------------------
    % function r = cl_fix_mult(a, a_fmt, b, b_fmt, r_fmt, [round], [saturate])
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
    
    % a = mat2py(a, a_fmt)
    varargin{1} = wide.mat2py(varargin{1}, varargin{2});
    
    % b = mat2py(b, b_fmt)
    varargin{3} = wide.mat2py(varargin{3}, varargin{4});
    
    % r = cl_fix_mult(a, a_fmt, b, b_fmt, r_fmt, [round], [saturate])
    r = py.en_cl_fix_pkg.cl_fix_mult(varargin{:});
    
    % r = py2mat(r, r_fmt)
    r = wide.py2mat(r, varargin{5});
end
