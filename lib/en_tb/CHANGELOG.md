## 1.0.0 (2024-05-10)

### Changed
* Changed `en_tb` to a fixed-name VHDL library (consistent with our usage of `vunit_lib`)

### Removed
* File I/O support for `en_cl_fix` (and dependency on `en_cl_fix`)
* File I/O support for `psi_fix` (and dependency on `psi_fix`)
* Testbench dependency on `en_cl`

## 0.3.0 (2024-02-26)

### Changed
* Refactor write/read functions
* Compatibility with `en_cl` and  `en_cl_fix`

### Removed
* File I/O support for binary files

## 0.2.0 (2022-09-15)

### Added
* File I/O support for `en_cl_fix`
* File I/O support for `psi_fix`

### Changed
* Update simulation scripts (ModelSim 2020+ support)

## 0.1.1 (2022-01-17)

### Fixed
* VHDL context support

## 0.1.0 (2021-09-13)

### Added
* Library setup
* File I/O packages