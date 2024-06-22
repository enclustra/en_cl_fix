from .en_cl_fix_types import FixFormat
from .en_cl_fix import cl_fix_is_wide

import numpy as np

def to_uint64_array(data, fmt : FixFormat):
    """
    Packs "wide" (arbitrary-precision) fixed-point data into uint64s (e.g. for passing to MATLAB).
    
    The stacking is done along a new array dimension. So, result.ndim == max(data.ndim, 1) + 1,
    where the stacking is done along the final dimension.
    """
    # Input checks
    assert cl_fix_is_wide(fmt), "Fixed-point format must be wide fixed-point"
    if isinstance(data, np.ndarray):
        assert data.dtype == object, "Wide fixed-point data type must be Python int."
        assert isinstance(data.flat[0], int), "Wide fixed-point data type must be Python int."
        # Convert to >= 1D array
        data = np.atleast_1d(data)
    else:
        assert isinstance(data, int), "Wide fixed-point data type must be Python int."
        # Convert to 1D array
        data = np.array([data], dtype=object)
    
    # Calculate number of uint64s needed per element
    n_ints = (fmt.width + 63) // 64  # ceil(width / 64)

    # Cast signed data to unsigned by reintepreting the sign bit
    if fmt.S == 1:
        data = np.where(data < 0, data + 2**fmt.width, data)
    
    # Populate uint64 array
    result = np.empty(data.shape + (n_ints,), dtype=np.uint64)
    for i in range(n_ints):
        result[..., i] = data % 2**64
        data >>= 64
    
    return result

def from_uint64_array(data, fmt : FixFormat):
    """
    Unpacks uint64 data (e.g. from MATLAB) into "wide" arbitrary-precision fixed-point data.
    
    The input data is stacked along the final array dimension, so result.shape == data.shape[:-1].
    """
    assert cl_fix_is_wide(fmt), "Fixed-point format must be wide fixed-point"
    assert isinstance(data, np.ndarray), f"Unexpected input type. Expected: np.ndarray. Got: {type(data)}."
    assert data.dtype == np.uint64, f"Unexpected input dtype. Expected: np.uint64. Got: {data.dtype}."
    
    # Weighted sum to recombine uint64s into wide *unsigned* integers
    weights = 2**(64*np.arange(data.shape[-1]).astype(object))
    result = np.matmul(data, weights.T)
    
    # Handle the sign bit
    if fmt.S == 1:
        result = np.where(result >= 2**(fmt.I+fmt.F), result - 2**(fmt.I+fmt.F+1), result)
    
    return result
