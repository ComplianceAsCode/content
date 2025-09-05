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

`ctest` is used to run the unit tests for the `ssg` python package that is in the repo.

## SCAPVal
We use [SCAPVal](https://csrc.nist.gov/Projects/scap-validation-program/Validation-Test-Content) to valid our content.
Since a separate download is required this test is disabled by default.
A working Java installation is also required for SCAPVal to work.
To enable this test pass following options to cmake:

* `-DENABLE_SCAPVAL13:BOOL=ON` - This enables SCAPVal
* `-DSCAPVAL_PATH='/opt/scapval/SCAP-Content-Validation-Tool-1.3.5/scapval-1.3.5.jar'` - This provides the path to the SCAPVal jar.
You will need to replace `/opt/scapval/SCAP-Content-Validation-Tool-1.3.5/scapval-1.3.5.jar` with the actual path the SCAPVAL jar on your system.

SCAPVal can be run with ctest using the following command `ctest -R 'scapval' --output-on-failure`.
