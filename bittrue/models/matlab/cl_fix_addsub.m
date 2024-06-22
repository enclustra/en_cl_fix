function r = cl_fix_addsub(varargin)
    % ---------------------------------------------------------------------------------------------
    % function r = cl_fix_addsub(a, a_fmt, b, b_fmt, add, r_fmt, [round], [saturate])
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
    
    % Inconsitency in the MATLAB<->Python interface sometimes causes shape mismatches for vectors.
    % Workaround: handle vectors as special cases;
    is_column = iscolumn(varargin{1});
    is_row = isrow(varargin{1});

    % a = mat2py(a, a_fmt)
    varargin{1} = wide.mat2py(varargin{1}, varargin{2});
    
    % b = mat2py(b, b_fmt)
    varargin{3} = wide.mat2py(varargin{3}, varargin{4});
    
    % Inconsitency in the MATLAB<->Python interface sometimes causes shape mismatches for vectors.
    % Workaround: explicitly reshape the "add" input to match the data shape.
    varargin{5} = py.numpy.array(varargin{5});
    if varargin{5}.size == varargin{1}.size
        varargin{5} = varargin{5}.reshape(varargin{1}.shape);
    end

    % r = cl_fix_addsub(a, a_fmt, b, b_fmt, add, r_fmt, [round], [saturate])
    r = py.en_cl_fix_pkg.cl_fix_addsub(varargin{:});
    
    % r = py2mat(r, r_fmt)
    r = wide.py2mat(r, varargin{6});

    % Handle vectors
    if is_column
        r = r(:);
    elseif is_row
        r = reshape(r, 1, []);
    end
end
