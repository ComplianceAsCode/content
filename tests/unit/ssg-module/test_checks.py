import os

import pytest

import ssg.checks


def test_get_oval_path():
    rule_obj = {
        'id': 'some_id',
        'dir': '/some/random/path/to/a/rule/called/some_id',
        'ovals': {
            'shared.xml': {}
        }
    }
    correct_path = os.path.join(rule_obj['dir'], "oval", "shared.xml")

    assert ssg.checks.get_oval_path(rule_obj, "shared") == correct_path
    assert ssg.checks.get_oval_path(rule_obj, "shared.xml") == correct_path

    with pytest.raises(ValueError):
        ssg.checks.get_oval_path(rule_obj, "missing")

    with pytest.raises(ValueError):
        ssg.checks.get_oval_path({'id': 'something'}, "missing_dir")

    with pytest.raises(ValueError):
        ssg.checks.get_oval_path({}, "missing_id")

    with pytest.raises(ValueError):
        ssg.checks.get_oval_path({'id': 'present', 'dir': '/'},
                                 "missing_ovals")


def test_is_cce_format_valid():
    icv = ssg.checks.is_cce_format_valid
    assert icv("CCE-27191-6")
    assert icv("CCE-7223-7")

    assert not icv("not-valid")
    assert not icv("1234-5")
    assert not icv("TBD")
    assert not icv("CCE-TBD")
    assert not icv("CCE-abcde-f")


def test_is_cce_value_valid():
    icv = ssg.checks.is_cce_value_valid
    assert icv("CCE-27191-6")
    assert icv("CCE-27223-7")

    assert not icv("1234-5")
    assert not icv("12345-6")

