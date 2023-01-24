function y = mat2np(x)
    % Convert ordinary MATLAB matrix to numpy.ndarray
    shape = int32(size(x));
    y = py.numpy.array(x(:)).reshape(shape, order='F');
end
