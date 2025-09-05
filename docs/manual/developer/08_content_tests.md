# Content Testing

The project has many tests that are run via `ctest` from [`cmake`](https://cmake.org/).
The tests are defined in `tests/CMakeLists.txt`.
All kinds tests ran with our `ctest` suite, including Python Unit tests, content validations, and if enabled Ansible syntax checks, among many others.
For help on how to run the tests please review the test section from the [Building ComplianceAsCode](02_building_complianceascode) guide.

## Python

### `MyPy`

Some utility scripts in the project are type checked with [mypy](http://mypy-lang.org/).
If you are writing a new Python file in the project you should consider using MyPy.
To add a script to be checked with mypy use the `mypy_test` macro in `tests/CMakeLists.txt`.

### Unit Tests

The `ctest` tool is used to run unit tests for the `ssg` Python package that is in the repository.
The `ctest` tool is not able to run unit tests with different versions of Python.
To run only unit tests without any special steps beforehand with different Python versions for the `ssg` Python package, it is recommended to use `tox`.

The `tox` creates a virtual environment that handles all dependencies defined in the test requirement file and performs unit tests with multiple versions of Python.
This way, you can test your changes with different versions of Python on your machine and don't have to wait for the upstream CI to check them for you.

#### Execute Unit Tests via `ctest`

```bash
cd build
rm -rf *
cmake ..
ctest -R python-unit-ssg-module
```

#### Execute Unit Tests via `tox`

Installation of `tox` and more advanced usage is described in [documentation](https://tox.wiki/en/4.11.3/).

*You must be in the root directory of the project before running the `tox` command.*

Runs tests with Python2.7, Python3.8, Python3.9 and Python3-latest on machine:

```bash
tox
```

With a specific Python version (replace `XX` with Python version):

```bash
tox -e pyXX
```

##### Other useful usage of Tox

Run Flake8:

```bash
tox -e flake8
```

Build Docs:

```bash
tox -e docs
```

## SCAPVal

We use [SCAPVal](https://csrc.nist.gov/Projects/scap-validation-program/Validation-Test-Content) to valid our content.
Since a separate download is required this test is disabled by default.
A working Java installation is also required for SCAPVal to work.
To enable this test pass following options to cmake:

* `-DENABLE_SCAPVAL13:BOOL=ON` - This enables SCAPVal
* `-DSCAPVAL_PATH='/opt/scapval/SCAP-Content-Validation-Tool-1.3.5/scapval-1.3.5.jar'` - This provides the path to the SCAPVal jar.
You will need to replace `/opt/scapval/SCAP-Content-Validation-Tool-1.3.5/scapval-1.3.5.jar` with the actual path the SCAPVAL jar on your system.

SCAPVal can be run with ctest using the following command `ctest -R 'scapval' --output-on-failure`.

## SRG and STIG Mapping
This test ensures that rules with `stigid` reference also have a `srg` reference.
This test is an opt-in test per product, but ran by default.
This uses the build datastreams so the project must be rebuilt in order for changes to be reflected in the results.

The macro `stig_srg_mapping` in `tests/CMakeList.txt` should be used when adding a product for this test.

This script uses `tests/stig_srg_mapping.py` to run the test.

## Removed Rules
This test ensures no rules are removed from the data stream.
This test requires a built version of the "old" content to compare.
In CI we use the last upstream release.
Curently, this is only enabled for RHEL products.
To run this test on your own machine follow the example below.
You should replace `0.1.76` with the latest release of the project.

1. `wget https://github.com/ComplianceAsCode/content/releases/download/v0.1.76/scap-security-guide-0.1.76.zip`
1. `unzip scap-security-guide-0.1.76.zip`
1. `export ADDITIONAL_CMAKE_OPTIONS="-DENABLE_CHECK_RULE_REMOVAL:BOOL=ON -DOLD_RELEASE_DIR=full/path/to/unziped/scap-security-guide-0.1.76"`
1. `./build_product rhel10 rhel8 rhel9`
1. `cd build`
1. `ctest -R  rule-removal --output-on-failure`
