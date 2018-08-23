import os

import pytest

import ssg.rule_dir_stats as rds


def test_missing_oval():
    good_rule = {
        "id": "good_rule",
        "ovals": {
            "shared.xml": {}
        }
    }
    bad_rule = {
        "id": "bad_rule",
        "ovals": {}
    }

    assert not rds.missing_oval(good_rule)
    assert rds.missing_oval(bad_rule)


def test_missing_remediation():
    good_rule = {
        "id": "good_rule",
        "remediations": {
            "bash": {
                "shared.sh": {}
            }
        }
    }
    bad_rule = {
        "id": "bad_rule",
        "remediations": {
            "bash": {}
        }
    }

    assert not rds.missing_remediation(good_rule, 'bash')
    assert rds.missing_remediation(bad_rule, 'bash')
    assert rds.missing_remediation(bad_rule, 'anaconda')
