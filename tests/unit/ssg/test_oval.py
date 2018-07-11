import pytest

import ssg.oval


def test_find_existing_testfile():
    assert ssg.oval.find_testfile("disable_prelink.xml")


def test_dont_find_missing_testfile():
    assert ssg.oval.find_testfile("disable_prelinkxxx.xml") is None
