import pytest

import os
import ssg.build_remediations as sbr

data_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "data"))
rule_dir = os.path.join(data_dir, "group_dir", "rule_dir")
rhel_bash = os.path.join(rule_dir, "bash", "rhel.sh")


def test_is_applicable_for_product():
    assert sbr.is_applicable_for_product("multi_platform_all", "rhel7")
    assert sbr.is_applicable_for_product("multi_platform_rhel", "rhel7")
    assert sbr.is_applicable_for_product("multi_platform_rhel,multi_platform_ol", "rhel7")
    assert sbr.is_applicable_for_product("Red Hat Enterprise Linux 7", "rhel7")
    assert not sbr.is_applicable_for_product("Red Hat Enterprise Linux 7", "rhel6")
    assert not sbr.is_applicable_for_product("multi_platform_ol", "rhel7")


def test_is_supported_file_name():
    assert sbr.is_supported_filename('bash', 'something.sh')
    assert not sbr.is_supported_filename('bash', 'something.py')


def do_test_contents(remediation, config):
    assert 'do_something_magical' in remediation
    assert '# a random comment' in remediation
    assert len(remediation) == 3

    assert 'platform' in config
    assert 'reboot' in config
    assert 'complexity' in config
    assert 'strategy' in config
    assert 'disruption' in config

    assert sbr.is_applicable_for_product(config['platform'], 'rhel7')
    assert sbr.is_applicable_for_product(config['platform'], 'fedora')
    assert not sbr.is_applicable_for_product(config['platform'], 'rhel6')
    assert not sbr.is_applicable_for_product(config['platform'], 'ol7')

    assert 'false' == config['reboot']
    assert 'low' == config['complexity']
    assert 'configure' == config['strategy']
    assert 'low' == config['disruption']


def test_parse_from_file_with_jinja():
    remediation, config = sbr.parse_from_file_with_jinja(rhel_bash, {})
    do_test_contents(remediation, config)


def test_process_fix():
    fixes = {}
    sbr.process_fix(fixes, 'bash', {}, 'rhel7', rhel_bash, 'rule_dir')

    assert 'rule_dir' in fixes
    assert len(fixes['rule_dir']) == 2
    do_test_contents(fixes['rule_dir'].contents, fixes['rule_dir'].config)
