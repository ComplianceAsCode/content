import os

import ssg.build_remediations as sbr
import ssg.utils
from ssg.yaml import ordered_load

DATADIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "data"))
rule_dir = os.path.join(DATADIR, "group_dir", "rule_dir")
rhel_bash = os.path.join(rule_dir, "bash", "rhel.sh")


def test_is_supported_file_name():
    assert sbr.is_supported_filename('bash', 'something.sh')
    assert not sbr.is_supported_filename('bash', 'something.py')


def do_test_contents(remediation, config):
    assert 'do_something_magical' in remediation
    assert '# a random comment' in remediation

    assert 'platform' in config
    assert 'reboot' in config
    assert 'complexity' in config
    assert 'strategy' in config
    assert 'disruption' in config

    assert ssg.utils.is_applicable_for_product(config['platform'], 'rhel7')
    assert ssg.utils.is_applicable_for_product(config['platform'], 'fedora')
    assert not ssg.utils.is_applicable_for_product(config['platform'], 'rhel8')
    assert not ssg.utils.is_applicable_for_product(config['platform'], 'ol7')

    assert 'false' == config['reboot']
    assert 'low' == config['complexity']
    assert 'configure' == config['strategy']
    assert 'low' == config['disruption']


def test_parse_from_file_with_jinja():
    remediation, config = sbr.parse_from_file_with_jinja(rhel_bash, {})
    do_test_contents(remediation, config)


def test_process_fix():
    remediation_cls = sbr.REMEDIATION_TO_CLASS["bash"]

    fixes = {}

    env_yaml = dict(product="rhel7")
    remediation_obj = remediation_cls(rhel_bash)
    sbr.process(remediation_obj, env_yaml, fixes, "rule_dir")

    assert 'rule_dir' in fixes
    assert len(fixes['rule_dir']) == 2
    do_test_contents(fixes['rule_dir'].contents, fixes['rule_dir'].config)


def test_ansible_class():
    remediation = sbr.AnsibleRemediation.from_snippet_and_rule(
        os.path.join(DATADIR, "ansible.yml"), os.path.join(DATADIR, "file_owner_grub2_cfg.yml")
    )

    remediation.parse_from_file_with_jinja(dict())

    assert remediation.metadata["reboot"] == 'false'
    assert remediation.metadata["strategy"] == 'configure'
    assert remediation.metadata["complexity"] == 'low'
    assert remediation.metadata["disruption"] == 'low'


def test_ansible_conformance():
    remediation = sbr.AnsibleRemediation.from_snippet_and_rule(
        os.path.join(DATADIR, "ansible.yml"), os.path.join(DATADIR, "file_owner_grub2_cfg.yml")
    )
    ref_remediation_dict = ordered_load(open(os.path.join(DATADIR, "ansible-resolved.yml")))

    env_yaml = dict(product="rhel7")

    remediation.parse_from_file_with_jinja(env_yaml)
    # The comparison has to be done this way due to possible order variations,
    # which don't matter, but they make tests to fail.
    assert set(remediation.body[0]["tags"]) == set(ref_remediation_dict[0]["tags"])
    assert set(remediation.body[1]["tags"]) == set(ref_remediation_dict[1]["tags"])
    assert set(remediation.body[0]["when"]) == set(ref_remediation_dict[0]["when"])
    assert set(remediation.body[1]["when"]) == set(ref_remediation_dict[1]["when"])
    assert remediation.body[0]["name"] == ref_remediation_dict[0]["name"]
    assert remediation.body[1]["name"] == ref_remediation_dict[1]["name"]


def test_get_rule_dir_remediations():
    bash = sbr.get_rule_dir_remediations(rule_dir, 'bash')
    bash_files = list(map(os.path.basename, bash))

    assert len(bash) == 2
    assert 'something.sh' in bash_files
    assert 'rhel.sh' in bash_files

    rhel_bash = sbr.get_rule_dir_remediations(rule_dir, 'bash', 'rhel')
    assert len(rhel_bash) == 1
    assert rhel_bash[0].endswith('/rhel.sh')

    ol_bash = sbr.get_rule_dir_remediations(rule_dir, 'bash', 'ol')
    assert len(ol_bash) == 0

    something_bash = sbr.get_rule_dir_remediations(rule_dir, 'bash', 'something')
    assert len(something_bash) == 1
    assert something_bash != rhel_bash
