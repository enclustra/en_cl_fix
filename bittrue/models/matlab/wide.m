classdef wide
    % ------------------------------------------------------------------------------
    % This class provides functions to support "wide" (arbitrary-precision)
    % fixed-point numbers. These functions require MATLAB's Fixed-Point Designer
    % toolbox.
    %
    % For ordinary "narrow" fixed-point numbers (<= 53 bits), the Fixed-Point
    % Designer toolbox is not required.
    % ------------------------------------------------------------------------------
    
    % =============================================================================================
    % PUBLIC METHODS
    % =============================================================================================
    methods (Static = true)
        function y = py2mat(x, x_fmt)
            if cl_fix_is_wide(x_fmt)
                % Wide fixed-point conversion from Python to MATLAB fi()
                y = wide.py2fi(x, x_fmt);
            else
                % Narrow fixed-point (float)
                y = py2mat(x);
            end
        end
        
        function y = mat2py(x, x_fmt)
            if cl_fix_is_wide(x_fmt)
                % Wide fixed-point conversion from MATLAB fi() to Python
                y = wide.fi2py(x);
            else
                % Narrow fixed-point (float)
                y = mat2py(x);
            end
        end
        
        function [s,w,f,i] = fmt2swf(fmt)
            s = double(fmt.S);
            w = double(cl_fix_width(fmt));
            f = double(fmt.F);
            i = double(fmt.I);
        end
        
        function [s,w,f,i] = fi2swf(x)
            s = issigned(x);
            w = x.WordLength;
            f = x.FractionLength;
            i = w-f-s;
        end
        
        function fmt = swf2fmt(s, w, f)
            fmt = cl_fix_format(s, w-f-s, f);
        end
        
        function fmt = fi2fmt(x)
            [s, w, f] = wide.fi2swf(x);
            fmt = wide.swf2fmt(s, w, f);
        end
    end
    
    % =============================================================================================
    % PRIVATE METHODS
    % =============================================================================================
    methods (Static = true, Access = private)
        function y = py2fi(x, x_fmt)
            % ------------------------------------------------------------------------------
            % function y = py2fi(x, x_fmt)
            % ------------------------------------------------------------------------------
            % Converts "wide" (arbitrary-precision) fixed-point Python data to MATLAB fi().
            % ------------------------------------------------------------------------------
            
            % Convert wide (arbitrary-precision) fixed-point data to uint64s
            x = py.en_cl_fix_pkg.to_uint64_array(x, x_fmt);
            
            % The uint64s are expanded along an extra dimension. If w<=64, then that dimension is
            % a singleton and will be lost in MATLAB. Therefore, we record ndim now.
            ndim = x.ndim - 1;
            
            % Convert to native MATLAB type
            x = uint64(x);
            
            % Convert fmt from FixFormat to fi() [s,w,f] parameterization
            [s,w,f] = wide.fmt2swf(x_fmt);
            
            % Concatenate 64-bit integers
            n_ints = size(x, ndim+1);
            x = fi(x, 0, n_ints*64, 0);
            idx = repmat({':'}, ndim+1, 1);  % Ugly indexing trick to slice n-D array.
            idx{end} = 1;  % Select the first slice (64 LSBs).
            y = x(idx{:});
            for k = 2:n_ints
                idx{end} = k;  % Select the kth slice (64 bits).
                y = bitor(pow2(x(idx{:}), (k-1)*64), y);
            end
            
            % Truncate width from N*64 to w (unsigned integer)
            y = fi(y, 0, w, 0);
            
            % Reinterpret fixed-point format
            y = reinterpretcast(y, numerictype(s,w,f));
        end
        
        function y = fi2py(x)
            fmt = wide.fi2fmt(x);
            w = cl_fix_width(fmt);
            
            % Calculate number of uint64s needed per element
            n_ints = ceil(w / 64);
            
            % Cast data to unsigned integer
            x = reinterpretcast(x, numerictype(0,w,0));
            
            % Populate uint64 array
            ndim = ndims(x);
            shape = [size(x), n_ints];  % Create new dimension for stacking uint64s.
            y = zeros(shape, 'uint64');
            idx = repmat({':'}, ndim+1, 1);  % Ugly indexing trick to slice n-D array.
            mask = fi(intmax('uint64'), x.numerictype);  % 2^64 - 1.
            for k = 1:n_ints
                idx{end} = k;  % Write the kth slice (64 bits).
                y(idx{:}) = uint64(bitand(x, mask));
                x = bitsrl(x, 64);  % x >>= 64.
            end
            
            % Convert uint64s to wide (arbitrary-precision) fixed-point data
            y = mat2py(y);
            y = py.en_cl_fix_pkg.from_uint64_array(y, fmt);
        end
    end
end
