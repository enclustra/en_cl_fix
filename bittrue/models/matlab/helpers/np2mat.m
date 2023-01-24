function y = np2mat(x)
    % Convert numpy.ndarray to ordinary MATLAB matrix
    xx = x.reshape(x.shape, order='F'); % Force column-major layout.
    shape = double(py.array.array('d', py.numpy.atleast_2d(xx).shape));
    y = double(py.array.array('d', py.numpy.nditer(xx)));
    y = reshape(y, shape);
end
