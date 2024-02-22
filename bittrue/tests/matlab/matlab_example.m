% -------------------------------------------------------------------------------------------------
% Copyright (c) 2023 Enclustra GmbH, Switzerland (info@enclustra.com)
% -------------------------------------------------------------------------------------------------

% -------------------------------------------------------------------------------------------------
% Description:
%
% This script demonstrates basic execution of en_cl_fix functions in MATLAB, using MATLAB's native
% Python support.
% -------------------------------------------------------------------------------------------------

% -------------------------------------------------------------------------------------------------
% Environment Setup
% -------------------------------------------------------------------------------------------------
close all; clear all; clc;

% None of the documented methods for reloading en_cl_fix_pkg "in-process" work. Therefore, if we
% want to modify Python sources without restarting MATLAB, then we must execute Python "out of
% process". This is much slower to execute, but useful for debugging.
RELOAD_PYTHON_MODULES = false;
pe = pyenv;
if RELOAD_PYTHON_MODULES
    if strcmp(pe.Status, 'Loaded') && strcmp(pe.ExecutionMode, 'InProcess')
        error('MATLAB must be restarted to change the Python environment');
    end
    terminate(pe);
    pe = pyenv(ExecutionMode='OutOfProcess');
else
    if strcmp(pe.Status, 'NotLoaded')
        pe = pyenv(ExecutionMode='InProcess');
    else
        if strcmp(pe.ExecutionMode, 'OutOfProcess')
            error('MATLAB must be restarted to change the Python environment');
        end
    end
end

% Sanity check: Make sure MATLAB can find a Python installation.
assert(pe.Version ~= "", "Python installation not detected by MATLAB.");
disp(append('Detected Python version: ', pe.Version, '.'));

% Add Python sources to the Python path.
root = fileparts(mfilename('fullpath'));
python_src_path = fullfile(root, '..', '..', 'models', 'python');
insert(py.sys.path, int32(0), python_src_path);

% Load the en_cl_fix Python package.
py.importlib.import_module('en_cl_fix_pkg');

% Add MATLAB sources to MATLAB path
addpath(fullfile(root, '..', '..', 'models', 'matlab'));

% -------------------------------------------------------------------------------------------------
% Example Setup
% -------------------------------------------------------------------------------------------------

% Load shorthand constants
cl_fix_constants;

% Specify some input data formats.
a_fmt = cl_fix_format(1, 0, 15);
b_fmt = cl_fix_format(0, 2, 6);

% Check string conversion functions
disp(append('a_fmt = ', cl_fix_format_to_string(a_fmt)));
disp(append('b_fmt = ', cl_fix_format_to_string(b_fmt)));

% Generate some random input data.
Ndata = uint64(32768);
a = cl_fix_random(Ndata, a_fmt);
b = cl_fix_random(Ndata, b_fmt);

% -------------------------------------------------------------------------------------------------
% Example Arithmetic
% -------------------------------------------------------------------------------------------------

% Note: All of these examples get result formats from cl_fix_*_fmt functions. This means the
% results are guaranteed to be represented without loss (no rounding or saturation).

% Addition
add_fmt = cl_fix_add_fmt(a_fmt, b_fmt);
add_result = cl_fix_add(a, a_fmt, b, b_fmt, add_fmt);

% Subtraction
sub_fmt = cl_fix_sub_fmt(a_fmt, b_fmt);
sub_result = cl_fix_sub(a, a_fmt, b, b_fmt, sub_fmt);

% Add-sub
addsub = logical(randi([0,1], 1, Ndata));
addsub_fmt = cl_fix_addsub_fmt(a_fmt, b_fmt);
addsub_result = cl_fix_addsub(a, a_fmt, b, b_fmt, addsub, addsub_fmt);

% Multiplication
mult_fmt = cl_fix_mult_fmt(a_fmt, b_fmt);
mult_result = cl_fix_mult(a, a_fmt, b, b_fmt, mult_fmt);

% Absolute value
abs_fmt = cl_fix_abs_fmt(a_fmt);
abs_result = cl_fix_abs(a, a_fmt, abs_fmt);

% Negative value
neg_fmt = cl_fix_neg_fmt(a_fmt);
neg_result = cl_fix_neg(a, a_fmt, neg_fmt);

% Bit-shift
shift_size = -3; % Negative value => right shift.
shift_fmt = cl_fix_shift_fmt(a_fmt, shift_size);
shift_result = cl_fix_shift(a, a_fmt, shift_size, shift_fmt);

% -------------------------------------------------------------------------------------------------
% Arithmetic Result Checking
% -------------------------------------------------------------------------------------------------

% All data formats in this script fit inside double-precision floats. This means we don't need to
% handle arbitrary precision data.
assert(~cl_fix_is_wide(a_fmt), 'Unexpected wide a_fmt.');
assert(~cl_fix_is_wide(b_fmt), 'Unexpected wide b_fmt.');

% Note: All of the example results are guaranteed to be represented without loss. So, we can just
% check against ordinary double-precision arithmetic.

% Addition
assert(~cl_fix_is_wide(add_fmt), 'Unexpected wide add_fmt.');
add_expected = a + b;
assert(isequal(add_result, add_expected), 'Error in add');

% Subtraction
assert(~cl_fix_is_wide(sub_fmt), 'Unexpected wide sub_fmt.');
sub_expected = a - b;
assert(isequal(sub_result, sub_expected), 'Error in sub');

% Add-sub
assert(~cl_fix_is_wide(addsub_fmt), 'Unexpected wide addsub_fmt.');
addsub_expected = sub_expected;
addsub_expected(addsub) = add_expected(addsub);
assert(isequal(addsub_result, addsub_expected), 'Error in addsub');

% Multiplication
assert(~cl_fix_is_wide(mult_fmt), 'Unexpected wide mult_fmt.');
mult_expected = a .* b;
assert(isequal(mult_result, mult_expected), 'Error in mult');

% Absolute value
assert(~cl_fix_is_wide(abs_fmt), 'Unexpected wide abs_fmt.');
abs_expected = abs(a);
assert(isequal(abs_result, abs_expected), 'Error in abs');

% Negation
assert(~cl_fix_is_wide(neg_fmt), 'Unexpected wide neg_fmt.');
neg_expected = -a;
assert(isequal(neg_result, neg_expected), 'Error in neg');

% Bit-shifting
assert(~cl_fix_is_wide(shift_fmt), 'Unexpected wide shift_fmt.');
shift_expected = a * 2^shift_size;
assert(isequal(shift_result, shift_expected), 'Error in shift');

% -------------------------------------------------------------------------------------------------
% Misc Functions
% -------------------------------------------------------------------------------------------------

% Here, we mostly just check that Python function calls succeed without error. Functionality of the
% Python implementation is tested separately.

% Rounding
round = Round.ConvEven_s;
round_fmt = cl_fix_round_fmt(a_fmt, a_fmt.F - 4, round);
round_result = cl_fix_round(a, a_fmt, round_fmt, round);

% Saturation
saturate = Sat.Sat_s;
sat_fmt = cl_fix_format(0, a_fmt.I - 4, a_fmt.F);
sat_result = cl_fix_saturate(a, a_fmt, sat_fmt, saturate);

% Rounding and saturation
resize_result = cl_fix_resize(a, a_fmt, b_fmt, round, saturate);

% Bit-width
assert(cl_fix_width(a_fmt) == a_fmt.S + a_fmt.I + a_fmt.F, 'Unexpected a_fmt width.');
assert(cl_fix_width(b_fmt) == b_fmt.S + b_fmt.I + b_fmt.F, 'Unexpected b_fmt width.');

% Integer representations
a_int = cl_fix_to_integer(a, a_fmt);
a_check = cl_fix_from_integer(a_int, a_fmt);
assert(isequal(a_check, a), 'Unexpected values after integer conversions.');

% Conversion from float
a_check = cl_fix_from_real(a, a_fmt, Sat.SatWarn_s);
assert(isequal(a_check, a), 'Unexpected values after float conversions');

% Max and min values
a_max = cl_fix_max_value(a_fmt);
a_min = cl_fix_min_value(a_fmt);
b_max = cl_fix_max_value(b_fmt);
b_min = cl_fix_min_value(b_fmt);

% Range checks
inrange_result = cl_fix_in_range(a, a_fmt, b_fmt);

% Generating zeros
zeros_a = cl_fix_zeros(10, a_fmt);
zeros_b = cl_fix_zeros([4,3], b_fmt);

disp('Test finished.');
