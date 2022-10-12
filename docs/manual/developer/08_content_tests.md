# Content Testing

The project has many tests that are run via `ctest` from [`cmake`](https://cmake.org/).
The tests are defined in `tests/CMakeLists.txt`.
All kinds tests ran with our `ctest` suite, including Python Unit tests, content validations, and if enabled Ansible syntax checks, among many others.
For help on how to run the tests please review the test section from the [Building ComplianceAsCode](02_building_complianceascode) guide.

## Python

### `MyPy`

Some utility scripts in the project are type checked with [mypy](http://mypy-lang.org/).
If you are writing a new Python file in the project you should consider using MyPy.
Add to your script to be type checked add path to your file in the `test-mypy` test in `tests/CMakeLists.txt`.

### Unit Tests

`ctest` is used to run the unit tests for the `ssg` python package that is in the repo.
