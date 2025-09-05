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


def test_prodtypes_oval():
    bad_rule = {
        "id": "bad_rule",
        "products": ["rhel8"],
        "ovals": {
            "rhel7.xml": {
                "products": ["rhel7"]
            }
        }
    }
    good_rule = {
        "id": "good_rule",
        "products": ["rhel7"],
        "ovals": {
            "rhel7.xml": {
                "products": ["rhel7"]
            }
        }
    }
    empty_rule = {
        "id": "empty_rule"
    }
    no_oval_rule = {
        "id": "empty_rule",
        "products": ["rhel7"]
    }

    assert rds.prodtypes_oval(bad_rule)
    assert not rds.prodtypes_oval(good_rule)
    assert not rds.prodtypes_oval(empty_rule)
    assert not rds.prodtypes_oval(no_oval_rule)


def test_prodtypes_remediation():
    bad_rule = {
        "id": "bad_rule",
        "products": ["rhel8"],
        "remediations": {
            "bash": {
                "rhel7.sh": {
                    "products": ["rhel7"]
                }
            }
        }
    }
    good_rule = {
        "id": "good_rule",
        "products": ["rhel7"],
        "remediations": {
            "bash": {
                "rhel7.sh": {
                    "products": ["rhel7"]
                }
            }
        }
    }
    empty_rule = {
        "id": "empty_rule"
    }
    no_remediation_rule = {
        "id": "empty_rule",
        "products": ["rhel7"]
    }

    assert rds.prodtypes_remediation(bad_rule, 'bash')
    assert not rds.prodtypes_remediation(good_rule, 'bash')
    assert not rds.prodtypes_remediation(empty_rule, 'bash')
    assert not rds.prodtypes_remediation(no_remediation_rule, 'bash')
    assert not rds.prodtypes_remediation(no_remediation_rule, 'ansible')
