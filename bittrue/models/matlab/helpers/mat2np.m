function y = mat2np(x)
    % Convert ordinary MATLAB matrix to numpy.ndarray.
    % Python is more strict about how it handles 0d / 1d / 2d arrays.
    if isscalar(x)
        shape = [];
    elseif isvector(x)
        shape = int32(numel(x));
    else
        shape = int32(size(x));
    end
    y = py.numpy.array(x(:)).reshape(shape, order='F');
end
