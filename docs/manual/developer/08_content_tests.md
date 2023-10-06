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
