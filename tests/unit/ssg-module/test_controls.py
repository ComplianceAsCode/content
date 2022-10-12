import pytest
import logging
import os

import ssg.controls
import ssg.build_yaml
from ssg.environment import open_environment
from ssg.products import load_product_yaml

ssg_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
data_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "data"))
controls_dir = os.path.join(data_dir, "controls_dir")
profiles_dir = os.path.join(data_dir, "profiles_dir")


def _load_test(profile):
    product_yaml = os.path.join(ssg_root, "products", "rhel8", "product.yml")
    build_config_yaml = os.path.join(ssg_root, "build", "build_config.yml")
    env_yaml = open_environment(build_config_yaml, product_yaml)
    controls_manager = ssg.controls.ControlsManager(controls_dir, env_yaml)
    controls_manager.load()
    c_r1 = controls_manager.get_control(profile, "R1")
    assert c_r1.title == "User session timeout"
    assert c_r1.description == "Remote user sessions must be closed after " \
                               "a certain period of inactivity."
    assert c_r1.automated == "yes"
    c_r1_rules = c_r1.selected
    assert "sshd_set_idle_timeout" in c_r1_rules
    assert "accounts_tmout" in c_r1_rules
    assert "var_accounts_tmout=10_min" not in c_r1_rules
    assert "var_accounts_tmout" in c_r1.variables
    assert c_r1.variables["var_accounts_tmout"] == "10_min"
    # abcd is a level-less policy
    assert c_r1.levels == ["default"]
    assert "vague" in c_r1.notes
    c_r2 = controls_manager.get_control(profile, "R2")
    assert c_r2.automated == "no"
    assert c_r2.notes == "This is individual depending on the system " \
                        "workload therefore needs to be audited manually."
    assert c_r2.rationale == "Minimization of configuration helps to reduce attack surface."
    c_r4 = controls_manager.get_control(profile, "R4")
    assert len(c_r4.selected) == 3
    c_r4_rules = c_r4.selected
    assert "accounts_passwords_pam_faillock_deny_root" in c_r4_rules
    assert "accounts_password_pam_minlen" in c_r4_rules
    assert "accounts_password_pam_ocredit" in c_r4_rules
    assert "var_password_pam_ocredit" in c_r4.variables
    assert c_r4.variables["var_password_pam_ocredit"] == "1"
    c_r5 = controls_manager.get_control(profile, "R5")
    assert c_r5.id == "R5"
    assert c_r5.status == "does not meet"
    assert c_r5.fixtext == "There is no fixtext."
    assert c_r5.check == "There is no check."
    assert "Although the listed mitigation is supporting the security function" in c_r5.mitigation
    assert c_r5.description == \
           "The operating system must provide automated mechanisms for supporting account " \
           "management functions."
    assert "Enterprise environments make account management challenging and complex." in \
           c_r5.rationale
    assert c_r5.status_justification == "Mitigate with third-party software."


def test_controls_load():
    _load_test("abcd")


def test_controls_levels():
    product_yaml = os.path.join(ssg_root, "products", "rhel8", "product.yml")
    build_config_yaml = os.path.join(ssg_root, "build", "build_config.yml")
    env_yaml = open_environment(build_config_yaml, product_yaml)
    controls_manager = ssg.controls.ControlsManager(controls_dir, env_yaml)
    controls_manager.load()

    # Default level is the lowest level
    c_1 = controls_manager.get_control("abcd-levels", "S1")
    assert c_1.levels == ["low"]
    c_4 = controls_manager.get_control("abcd-levels", "S4")
    assert c_4.levels == ["low"]

    # Explicit levels
    c_2 = controls_manager.get_control("abcd-levels", "S2")
    assert c_2.levels == ["low"]

    c_3 = controls_manager.get_control("abcd-levels", "S3")
    assert c_3.levels == ["medium"]

    c_4a = controls_manager.get_control("abcd-levels", "S4.a")
    assert c_4a.levels == ["low"]

    c_4b = controls_manager.get_control("abcd-levels", "S4.b")
    assert c_4b.levels == ["high"]

    c_5 = controls_manager.get_control("abcd-levels", "S5")
    assert c_5.levels == ["low"]

    c_6 = controls_manager.get_control("abcd-levels", "S6")
    assert c_6.levels == ["medium"]

    c_7 = controls_manager.get_control("abcd-levels", "S7")
    assert c_7.levels == ["high"]

    # test if all crypto-policy controls have the rule selected
    assert "configure_crypto_policy" in c_5.selections
    assert "configure_crypto_policy" in c_6.selections
    assert "configure_crypto_policy" in c_7.selections

    # just the essential controls
    low_controls = controls_manager.get_all_controls_of_level(
        "abcd-levels", "low")
    # essential and more advanced together
    medium_controls = controls_manager.get_all_controls_of_level(
        "abcd-levels", "medium")
    high_controls = controls_manager.get_all_controls_of_level(
        "abcd-levels", "high")
    all_controls = controls_manager.get_all_controls("abcd-levels")

    assert len(high_controls) == len(all_controls)
    assert len(low_controls) <= len(high_controls)
    assert len(low_controls) == 5
    assert len(medium_controls) == 7

    # test overriding of variables in levels
    assert c_2.variables["var_password_pam_minlen"] == "1"
    assert "var_password_pam_minlen" not in c_3.variables.keys()
    assert c_4b.variables["var_password_pam_minlen"] == "2"

    variable_found = False
    for c in low_controls:
        if "var_password_pam_minlen" in c.variables.keys():
            variable_found = True
            assert c.variables["var_password_pam_minlen"] == "1"
    assert variable_found

    variable_found = False
    for c in medium_controls:
        if "var_password_pam_minlen" in c.variables.keys():
            variable_found = True
            assert c.variables["var_password_pam_minlen"] == "1"
    assert variable_found

    variable_found = False
    for c in high_controls:
        if "var_password_pam_minlen" in c.variables.keys():
            variable_found = True
            assert c.variables["var_password_pam_minlen"] == "2"
    assert variable_found

    # now test if controls of lower level has the variable definition correctly removed
    # because it is overriden by higher level controls
    s2_high = [c for c in high_controls if c.id == "S2"]
    assert len(s2_high) == 1
    assert "var_some_variable" not in s2_high[0].variables.keys()
    assert "var_password_pam_minlen" not in s2_high[0].variables.keys()
    s4b_high = [c for c in high_controls if c.id == "S4.b"]
    assert len(s4b_high) == 1
    assert s4b_high[0].variables["var_some_variable"] == "3"
    assert s4b_high[0].variables["var_password_pam_minlen"] == "2"

    # check that in low level the variable is correctly placed there in S2
    s2_low = [c for c in low_controls if c.id == "S2"]
    assert len(s2_low) == 1
    assert s2_low[0].variables["var_some_variable"] == "1"
    assert s2_low[0].variables["var_password_pam_minlen"] == "1"

    # check that low, medium and high levels have crypto policy selected
    s5_low = [c for c in low_controls if c.id == "S5"]
    assert len(s5_low) == 1
    assert "configure_crypto_policy" in s5_low[0].selections

    s5_medium = [c for c in medium_controls if c.id == "S5"]
    assert len(s5_medium) == 1
    assert "configure_crypto_policy" in s5_medium[0].selections
    s6_medium = [c for c in medium_controls if c.id == "S6"]
    assert len(s6_medium) == 1
    assert "configure_crypto_policy" in s6_medium[0].selections

    s5_high = [c for c in high_controls if c.id == "S5"]
    assert len(s5_high) == 1
    assert "configure_crypto_policy" in s5_high[0].selections
    s6_high = [c for c in high_controls if c.id == "S6"]
    assert len(s6_high) == 1
    assert "configure_crypto_policy" in s6_high[0].selections
    s7_high = [c for c in high_controls if c.id == "S7"]
    assert len(s7_high) == 1
    assert "configure_crypto_policy" in s7_high[0].selections


def test_controls_load_product():
    product_yaml = os.path.join(ssg_root, "products", "rhel8", "product.yml")
    build_config_yaml = os.path.join(ssg_root, "build", "build_config.yml")
    env_yaml = open_environment(build_config_yaml, product_yaml)

    controls_manager = ssg.controls.ControlsManager(controls_dir, env_yaml)
    controls_manager.load()

    c_r1 = controls_manager.get_control("abcd", "R1")
    assert c_r1.title == "User session timeout"
    assert c_r1.description == "Remote user sessions must be closed after " \
        "a certain period of inactivity."
    assert c_r1.automated == "yes"

    c_r1_rules = c_r1.selected
    assert "sshd_set_idle_timeout" in c_r1_rules
    assert "accounts_tmout" in c_r1_rules
    assert "var_accounts_tmout=10_min" not in c_r1_rules
    assert "var_accounts_tmout" in c_r1.variables
    assert c_r1.variables["var_accounts_tmout"] == "10_min"


def test_profile_resolution_inline():
    profile_resolution(
        ssg.build_yaml.ProfileWithInlinePolicies, "abcd-low-inline")


def test_profile_resolution_extends_inline():
    profile_resolution_extends(
        ssg.build_yaml.ProfileWithInlinePolicies,
        "abcd-low-inline", "abcd-high-inline")


def test_profile_resolution_all_inline():
    profile_resolution_all(
        ssg.build_yaml.ProfileWithInlinePolicies, "abcd-all-inline")


class DictContainingAnyRule(dict):
    def __getitem__(self, key):
        rule = ssg.build_yaml.Rule(key)
        rule.product = "all"
        return rule

    def __contains__(self, rid):
        return True


def profile_resolution(cls, profile_low):
    product_yaml = os.path.join(ssg_root, "products", "rhel8", "product.yml")
    build_config_yaml = os.path.join(ssg_root, "build", "build_config.yml")
    env_yaml = open_environment(build_config_yaml, product_yaml)

    controls_manager = ssg.controls.ControlsManager(controls_dir, env_yaml)
    controls_manager.load()
    low_profile_path = os.path.join(profiles_dir, profile_low + ".profile")
    profile = cls.from_yaml(low_profile_path, env_yaml)
    all_profiles = {"abcd-low": profile}
    rules_by_id = DictContainingAnyRule()

    profile.resolve(all_profiles, rules_by_id, controls_manager=controls_manager)

    # Profile 'abcd-low' selects controls R1, R2, R3 from 'abcd' policy,
    # which should add the following rules to the profile:
    selected = profile.get_rule_selectors()
    assert "sshd_set_idle_timeout" in selected
    assert "accounts_tmout" in selected
    assert "configure_crypto_policy" in selected
    assert "var_accounts_tmout" in profile.variables

    # The rule "security_patches_up_to_date" has been selected directly
    # by profile selections, not by using controls, so it should be in
    # the resolved profile as well.
    assert "security_patches_up_to_date" in selected


def profile_resolution_extends(cls, profile_low, profile_high):
    product_yaml = os.path.join(ssg_root, "products", "rhel8", "product.yml")
    build_config_yaml = os.path.join(ssg_root, "build", "build_config.yml")
    env_yaml = open_environment(build_config_yaml, product_yaml)

    # tests ABCD High profile which is defined as an extension of ABCD Low
    controls_manager = ssg.controls.ControlsManager(controls_dir, env_yaml)
    controls_manager.load()

    low_profile_path = os.path.join(profiles_dir, profile_low + ".profile")
    low_profile = cls.from_yaml(low_profile_path, env_yaml)
    high_profile_path = os.path.join(profiles_dir, profile_high + ".profile")
    high_profile = cls.from_yaml(high_profile_path, env_yaml)
    all_profiles = {profile_low: low_profile, profile_high: high_profile}
    rules_by_id = DictContainingAnyRule()

    high_profile.resolve(all_profiles, rules_by_id, controls_manager=controls_manager)

    # Profile 'abcd-high' selects controls R1, R2, R3 from 'abcd' policy,
    # which should add the following rules to the profile:
    selected = high_profile.get_rule_selectors()
    assert "sshd_set_idle_timeout" in selected
    assert "accounts_tmout" in selected
    assert "configure_crypto_policy" in selected
    assert "var_accounts_tmout" in high_profile.variables

    # The rule "security_patches_up_to_date" has been selected directly by the
    # abcd-low profile selections, not by using controls, so it should be
    # in the resolved profile as well.
    assert "security_patches_up_to_date" in selected

    assert "accounts_passwords_pam_faillock_deny_root" in selected
    assert "accounts_password_pam_minlen" in selected
    assert "accounts_password_pam_ocredit" in selected
    assert "var_password_pam_ocredit" in high_profile.variables
    assert high_profile.variables["var_password_pam_ocredit"] == "2"


def profile_resolution_all(cls, profile_all):
    product_yaml = os.path.join(ssg_root, "products", "rhel8", "product.yml")
    build_config_yaml = os.path.join(ssg_root, "build", "build_config.yml")
    env_yaml = open_environment(build_config_yaml, product_yaml)

    controls_manager = ssg.controls.ControlsManager(controls_dir, env_yaml)
    controls_manager.load()
    profile_path = os.path.join(profiles_dir, profile_all + ".profile")
    profile = cls.from_yaml(profile_path, env_yaml)
    all_profiles = {profile_all: profile}
    rules_by_id = DictContainingAnyRule()

    profile.resolve(all_profiles, rules_by_id, controls_manager=controls_manager)

    # Profile 'abcd-all' selects all controls from 'abcd' policy,
    # which should add the following rules and variables to the profile:
    selected = profile.get_rule_selectors()
    assert "sshd_set_idle_timeout" in selected
    assert "accounts_tmout" in selected
    assert "var_accounts_tmout" in profile.variables
    assert profile.variables["var_accounts_tmout"] == "10_min"
    assert "configure_crypto_policy" in selected
    # Rule "systemd_target_multi_user" is only "related_rules"
    # therefore it should not appear in the resolved profile.
    assert "systemd_target_multi_user" not in selected
    assert "accounts_passwords_pam_faillock_deny_root" in selected
    assert "accounts_password_pam_minlen" in selected
    assert "accounts_password_pam_ocredit" in selected
    assert "var_password_pam_ocredit" in profile.variables
    assert profile.variables["var_password_pam_ocredit"] == "1"

    # The rule "security_patches_up_to_date" has been selected directly
    # by profile selections, not by using controls, so it should be in
    # the resolved profile as well.
    assert "security_patches_up_to_date" in selected


def test_load_control_from_folder():
    _load_test("qrst")


def test_load_control_from_folder_and_file():
    _load_test("jklm")


def test_load_control_from_specific_folder_and_file():
    _load_test("nopq")
