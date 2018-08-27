import pytest

import os
import ssg.rules

data_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "data"))
rule_dir = os.path.join(data_dir, "group_dir", "rule_dir")


def test_is_applicable():
    assert ssg.rules.is_applicable('all', 'rhel7')
    assert ssg.rules.is_applicable('multi_platform_all', 'rhel7')
    assert ssg.rules.is_applicable('rhel7', 'rhel7')
    assert ssg.rules.is_applicable('multi_platform_rhel', 'rhel7')
    assert ssg.rules.is_applicable('Red Hat Enterprise Linux 7', 'rhel7')

    assert ssg.rules.is_applicable('all', 'rhel-osp7')
    assert ssg.rules.is_applicable('multi_platform_rhel-osp', 'rhel-osp7')
    assert ssg.rules.is_applicable('rhel-osp7', 'rhel-osp7')
    assert ssg.rules.is_applicable('Red Hat OpenStack Platform 7', 'rhel-osp7')
    assert not ssg.rules.is_applicable('rhel7', 'rhel-osp7')

    assert not ssg.rules.is_applicable('rhel-osp7', 'rhel7')
    assert not ssg.rules.is_applicable('fedora,multi_platform_ubuntu', 'rhel7')
    assert not ssg.rules.is_applicable('ol7', 'rhel7')
    assert not ssg.rules.is_applicable('fedora,debian8', 'rhel7')


def test_get_rule_dir_id():
    assert ssg.rules.get_rule_dir_id("/some/path/fix_all_vulns/rule.yml") == "fix_all_vulns"
    assert ssg.rules.get_rule_dir_id("/some/path/fix_all_vulns") == "fix_all_vulns"
    assert ssg.rules.get_rule_dir_id(rule_dir) == 'rule_dir'


def test_is_rule_dir():
    assert ssg.rules.is_rule_dir(rule_dir)


def test__applies_to_product():
    assert ssg.rules._applies_to_product('shared', None)
    assert ssg.rules._applies_to_product('rhel', None)
    assert ssg.rules._applies_to_product('shared', 'rhel')
    assert ssg.rules._applies_to_product('rhel', 'rhel')
    assert not ssg.rules._applies_to_product('ol', 'rhel')


def test_find_rule_dirs():
    rule_dirs = list(ssg.rules.find_rule_dirs(data_dir))
    rule_ids = list(map(ssg.rules.get_rule_dir_id, rule_dirs))

    assert rule_dir in rule_dirs
    assert 'rule_dir' in rule_ids
    assert 'random_dir' not in rule_ids


def test_get_rule_dir_ovals():
    ovals = ssg.rules.get_rule_dir_ovals(rule_dir)
    oval_files = list(map(os.path.basename, ovals))

    assert len(ovals) == 2
    assert 'shared.xml' in oval_files
    assert 'rhel.xml' in oval_files
    assert oval_files.index('shared.xml') > oval_files.index('rhel.xml')

    rhel_ovals = ssg.rules.get_rule_dir_ovals(rule_dir, 'rhel')
    assert rhel_ovals == ovals

    ol_ovals = ssg.rules.get_rule_dir_ovals(rule_dir, 'ol')
    assert ol_ovals != ovals
    assert len(ol_ovals) == 1
    assert 'rhel.xml' not in ol_ovals


def test_get_rule_dir_remediations():
    bash = ssg.rules.get_rule_dir_remediations(rule_dir, 'bash')
    bash_files = list(map(os.path.basename, bash))

    assert len(bash) == 2
    assert 'something.sh' in bash_files
    assert 'rhel.sh' in bash_files

    rhel_bash = ssg.rules.get_rule_dir_remediations(rule_dir, 'bash', 'rhel')
    assert len(rhel_bash) == 1
    assert rhel_bash[0].endswith('/rhel.sh')

    ol_bash = ssg.rules.get_rule_dir_remediations(rule_dir, 'bash', 'ol')
    assert len(ol_bash) == 0

    something_bash = ssg.rules.get_rule_dir_remediations(rule_dir, 'bash', 'something')
    assert len(something_bash) == 1
    assert something_bash != rhel_bash
