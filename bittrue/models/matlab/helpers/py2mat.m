% -------------------------------------------------------------------------------------------------
% function y = py2mat(x, fmt)
% -------------------------------------------------------------------------------------------------
% Converts Python fixed-point data to MATLAB fixed-point data.
% -------------------------------------------------------------------------------------------------
function y = py2mat(x)

    if isa(x, 'py.numpy.ndarray')
        % -------------------------------------------
        % -- NARROW (double-precision float) input --
        % -------------------------------------------
        assert(strcmp(char(x.dtype.name), 'float64'), 'Numpy ndarray must contain floats');
        
        y = np2mat(x);
    elseif isa(x, 'py.wide_fxp.wide_fxp')
        % ----------------------------------------------
        % -- WIDE (arbitrary-precision integer) input --
        % ----------------------------------------------
        
        % Convert FixFormat to fi() [s,w,f] parameterization
        [s,w,f] = swf_from_fmt(x.fmt);
    
        % Call the python member function to pack wide_fxp data into uint64s
        x = uint64(py.en_cl_fix_pkg.wide_fxp.wide_fxp.to_uint64_array(x));
    
        % Concatenate 64-bit sections
        Nints = size(x, 1);
        x = fi(x, 0, Nints*64, 0);
        y = x(1,:);
        for k = 2:Nints
            y = bitor(pow2(x(k,:), (k-1)*64), y);
        end
        
        % Truncate width from N*64 to w (unsigned integer)
        y = fi(y, 0, w, 0);
        
        % Reinterpret fixed-point format
        y = reinterpretcast(y, numerictype(s,w,f));
    else
        error(['Unexpected data class: ' class(x)]);
    end

end
