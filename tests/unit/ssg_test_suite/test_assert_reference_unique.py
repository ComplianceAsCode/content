import os
import pytest
import subprocess
import sys

if sys.version_info < (3, 0):
    try:
        # pytest v4.6 has allow_module_level
        pytest.skip("requires python3", allow_module_level=True)
    except TypeError:
        # older pytest v2.7 does not have it and it is implied
        pytest.skip("requires python3")

DATADIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "data"))
CMD = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..", "assert_reference_unique.py")
)


def test_assert_reference_unique_noop():
    p = subprocess.run(
        [CMD],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    assert p.returncode == 2


def test_assert_reference_unique_help():
    p = subprocess.run(
        [CMD, "--help"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    assert p.returncode == 0


def test_assert_reference_unique_nonexisting():
    p = subprocess.run(
        [CMD, os.path.join(DATADIR, "rule_reference_nonexisting"), "foo"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    assert p.returncode == 7


def test_assert_reference_unique_pass():
    p = subprocess.run(
        [CMD, os.path.join(DATADIR, "rule_reference_pass"), "foo"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    assert p.returncode == 0


def test_assert_reference_unique_fail():
    p = subprocess.run(
        [CMD, os.path.join(DATADIR, "rule_reference_fail"), "foo"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    assert p.returncode == 1
