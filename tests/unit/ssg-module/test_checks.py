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
