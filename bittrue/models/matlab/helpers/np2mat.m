function y = np2mat(x)
    % Convert numpy.ndarray to ordinary MATLAB matrix
    if int64(py.numpy.array(x).size) == 1
        % Scalar
        y = double(x);
        return;
    end
    xx = x.reshape(x.shape, pyargs('order','F')); % Force column-major layout.
    shape = double(py.array.array('d', py.numpy.atleast_2d(xx).shape));
    y = double(py.array.array('d', py.numpy.nditer(xx)));
    y = reshape(y, shape);
end
