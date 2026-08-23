import os
import pytest

import ssg.build_remediations as sbr
import ssg.utils
import ssg.products
from ssg.yaml import ordered_load

DATADIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "data"))
rule_dir = os.path.join(DATADIR, "group_dir", "rule_dir")
rhel_bash = os.path.join(rule_dir, "bash", "rhel.sh")


@pytest.fixture
def env_yaml():
    env_yaml = dict(product="rhel9")
    return env_yaml


@pytest.fixture
def cpe_platforms(env_yaml):
    platforms = dict()
    platform_path = os.path.join(DATADIR, "machine.yml")
    platform = ssg.build_yaml.Platform.from_yaml(platform_path, env_yaml)
    platforms[platform.name] = platform
    return platforms

@pytest.fixture
def cpe_platforms_with_version_comparison(env_yaml):
    platforms = dict()
    platform_path = os.path.join(DATADIR, "package_ntp_eq_1_0.yml")
    platform = ssg.build_yaml.Platform.from_yaml(platform_path, env_yaml)
    platforms[platform.name] = platform
    return platforms


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

    assert ssg.utils.is_applicable_for_product(config['platform'], 'rhel9')
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


def test_process_fix(env_yaml, cpe_platforms):
    remediation_cls = sbr.REMEDIATION_TO_CLASS["bash"]

    remediation_obj = remediation_cls(rhel_bash)
    result = sbr.process(remediation_obj, env_yaml, cpe_platforms)

    assert result is not None
    assert len(result) == 2
    do_test_contents(result.contents, result.config)


def test_ansible_class(env_yaml, cpe_platforms):
    remediation = sbr.AnsibleRemediation.from_snippet_and_rule(
        os.path.join(DATADIR, "ansible.yml"), os.path.join(DATADIR, "file_owner_grub2_cfg.yml")
    )

    remediation.parse_from_file(env_yaml, cpe_platforms)

    assert remediation.metadata["reboot"] == 'false'
    assert remediation.metadata["strategy"] == 'configure'
    assert remediation.metadata["complexity"] == 'low'
    assert remediation.metadata["disruption"] == 'low'


def test_ansible_conformance(env_yaml, cpe_platforms):
    remediation = sbr.AnsibleRemediation.from_snippet_and_rule(
        os.path.join(DATADIR, "ansible.yml"), os.path.join(DATADIR, "file_owner_grub2_cfg.yml")
    )
    ref_remediation_dict = ordered_load(open(os.path.join(DATADIR, "ansible-resolved.yml")))

    remediation.parse_from_file(env_yaml, cpe_platforms)
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

def test_parse_remediation_if_platform_has_version_comparison(cpe_platforms_with_version_comparison):
    remediation_cls = sbr.REMEDIATION_TO_CLASS["bash"]
    remediation_obj = remediation_cls(rhel_bash)
    conditionals = remediation_obj.get_stripped_conditionals("bash", ["package_ntp_eq_1_0"], cpe_platforms_with_version_comparison)
    assert conditionals == ["rpm --quiet -q ntp && { real=$(rpm -q --queryformat '%{VERSION}-%{RELEASE}' ntp); ver=1.0;[[ \"$real\" == \"$ver\" ]]; }"]


@pytest.fixture
def cpe_platforms_with_multiple_os(env_yaml):
    """
    Fixture providing multiple OS platforms with version comparisons.
    Used to test proper parenthesization when combining platform conditionals with OR operators.
    """
    platforms = dict()

    # Load RHEL platform
    rhel_platform_path = os.path.join(DATADIR, "platform_rhel_test.yml")
    rhel_platform = ssg.build_yaml.Platform.from_yaml(rhel_platform_path, env_yaml)
    platforms[rhel_platform.name] = rhel_platform

    # Load Oracle Linux platform
    ol_platform_path = os.path.join(DATADIR, "platform_ol_test.yml")
    ol_platform = ssg.build_yaml.Platform.from_yaml(ol_platform_path, env_yaml)
    platforms[ol_platform.name] = ol_platform

    # Load SLES platform
    sles_platform_path = os.path.join(DATADIR, "platform_sles_test.yml")
    sles_platform = ssg.build_yaml.Platform.from_yaml(sles_platform_path, env_yaml)
    platforms[sles_platform.name] = sles_platform

    return platforms


def test_bash_remediation_wraps_platform_conditionals_with_operators(cpe_platforms_with_multiple_os):
    """
    Regression test for proper wrapping of platform conditionals containing operators.

    When multiple platform conditionals are joined with OR (||), each conditional that
    contains operators (&& or ||) must be wrapped in parentheses to ensure proper
    bash short-circuit evaluation.

    Without proper wrapping:
        grep ... && { version_check } || grep ... && { version_check }
    causes all version checks to execute due to bash operator precedence.

    With proper wrapping:
        ( grep ... && { version_check } ) || ( grep ... && { version_check } )
    ensures only the matching platform's version check executes.
    """
    remediation_cls = sbr.REMEDIATION_TO_CLASS["bash"]
    remediation_obj = remediation_cls(rhel_bash)

    # Get conditionals for all three platforms
    platform_names = ["platform_rhel_test", "platform_ol_test", "platform_sles_test"]
    conditionals = remediation_obj.get_stripped_conditionals(
        "bash", platform_names, cpe_platforms_with_multiple_os
    )

    # Verify we got all three conditionals
    assert len(conditionals) == 3, f"Expected 3 conditionals, got {len(conditionals)}"

    # Each conditional should contain && operator (ID check && version check)
    for cond in conditionals:
        assert " && " in cond, f"Conditional should contain &&: {cond}"

    # Call the production wrapping method
    wrapped = sbr.BashRemediation.wrap_conditionals_with_operators(conditionals)

    # Verify all three conditionals are wrapped
    assert len(wrapped) == 3, f"Expected 3 wrapped conditionals, got {len(wrapped)}"

    # Verify each wrapped conditional is properly wrapped with parentheses
    for i, wrapped_cond in enumerate(wrapped):
        assert wrapped_cond.startswith("( "), \
            f"Conditional {i} should start with '( ': {wrapped_cond}"
        assert wrapped_cond.endswith(" )"), \
            f"Conditional {i} should end with ' )': {wrapped_cond}"
        # Verify the original conditional is preserved inside
        assert conditionals[i] in wrapped_cond, \
            f"Wrapped conditional {i} should contain original: {wrapped_cond}"

    # Verify conditionals without operators are not wrapped
    simple_conditionals = ["test -f /etc/os-release", "[ $UID -eq 0 ]"]
    wrapped_simple = sbr.BashRemediation.wrap_conditionals_with_operators(simple_conditionals)
    for i, wrapped_cond in enumerate(wrapped_simple):
        assert wrapped_cond == simple_conditionals[i], \
            f"Simple conditional {i} should not be wrapped: {wrapped_cond}"
