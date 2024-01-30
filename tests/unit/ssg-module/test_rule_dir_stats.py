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


def test_two_plus_oval():
    three_rule = {
        "id": "three_rule",
        "ovals": {
            "rhel6.xml": {},
            "rhel7.xml": {},
            "fedora.xml": {}
        }
    }
    two_rule = {
        "id": "two_rule",
        "ovals": {
            "rhel6.xml": {},
            "rhel7.xml": {}
        }
    }
    one_rule = {
        "id": "one_rule",
        "ovals": {
            "rhel6.xml": {},
        }
    }
    empty_rule = {
        "id": "bad_rule",
        "ovals": {}
    }

    assert rds.two_plus_oval(three_rule)
    assert rds.two_plus_oval(two_rule)
    assert not rds.two_plus_oval(one_rule)
    assert not rds.two_plus_oval(empty_rule)


def test_two_plus_remediation():
    three_rule = {
        "id": "three_rule",
        "remediations": {
            "bash": {
                "rhel6.sh": {},
                "rhel7.sh": {},
                "fedora.sh": {}
            }
        }
    }
    two_rule = {
        "id": "two_rule",
        "remediations": {
            "bash": {
                "rhel6.sh": {},
                "rhel7.sh": {}
            }
        }
    }
    one_rule = {
        "id": "one_rule",
        "remediations": {
            "bash": {
                "rhel7.sh": {}
            }
        }
    }
    empty_rule = {
        "id": "empty_rule",
        "remediations": {
            "bash": {}
        }
    }

    assert rds.two_plus_remediation(three_rule, 'bash')
    assert rds.two_plus_remediation(two_rule, 'bash')
    assert not rds.two_plus_remediation(one_rule, 'bash')
    assert not rds.two_plus_remediation(empty_rule, 'bash')
    assert not rds.two_plus_remediation(empty_rule, 'anaconda')
