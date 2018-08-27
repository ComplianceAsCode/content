import pytest

import ssg.checks


def test_is_cce_valid():
    icv = ssg.checks.is_cce_valid
    assert icv("CCE-27191-6")
    assert icv("CCE-7223-7")

    assert not icv("not-valid")
    assert not icv("1234-5")
    assert not icv("12345-6")
    assert not icv("TBD")
    assert not icv("CCE-TBD")
    assert not icv("CCE-abcde-f")
