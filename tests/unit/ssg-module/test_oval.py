import pytest

import os
import ssg.oval

data_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "data"))
rule_dir_oval = os.path.join(data_dir, "group_dir", "rule_dir", "oval")
rhel_oval = os.path.join(rule_dir_oval, "rhel.xml")
shared_oval = os.path.join(rule_dir_oval, "shared.xml")

def test_applicable_platforms():
    rap = ssg.oval.applicable_platforms(rhel_oval)
    assert len(rap) == 1
    assert 'Red Hat Enterprise Linux 7' in rap

    sap = ssg.oval.applicable_platforms(shared_oval)
    assert len(sap) == 4
    assert 'multi_platform_rhel' in sap
    assert 'multi_platform_fedora' in sap
    assert 'multi_platform_debian' in sap
    assert 'multi_platform_ubuntu' in sap


def test_find_existing_testfile():
    assert ssg.oval.find_testfile("disable_prelink.xml")


def test_dont_find_missing_testfile():
    assert ssg.oval.find_testfile("disable_prelinkxxx.xml") is None
