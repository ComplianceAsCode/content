import pytest
import logging
import os

import ssg.controls
import ssg.build_yaml
from ssg.environment import open_environment
from ssg.products import get_product_yaml

data_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "data"))
controls_dir = os.path.join(data_dir, "controls_dir")
profiles_dir = os.path.join(data_dir, "profiles_dir")


def test_controls_load():
    controls_manager = ssg.controls.ControlsManager(controls_dir)
    controls_manager.load()

    c_r1 = controls_manager.get_control("abcd", "R1")
    assert c_r1.title == "User session timeout"
    assert c_r1.description == "Remote user sessions must be closed after " \
        "a certain period of inactivity."
    assert c_r1.automated == "yes"
    assert "sshd_set_idle_timeout" in c_r1.rules
    assert "accounts_tmout" in c_r1.rules
    assert "var_accounts_tmout=10_min" not in c_r1.rules
    assert "var_accounts_tmout" in c_r1.variables
    assert c_r1.variables["var_accounts_tmout"] == "10_min"

    # abcd is a level-less policy
    assert c_r1.level == "default"

    assert "vague" in c_r1.notes

    c_r2 = controls_manager.get_control("abcd", "R2")
    assert c_r2.automated == "no"
    assert c_r2.note == "This is individual depending on the system " \
        "workload therefore needs to be audited manually."
    assert len(c_r2.rules) == 0

    assert not c_r2.notes

    c_r4 = controls_manager.get_control("abcd", "R4")
    assert len(c_r4.rules) == 3
    assert "accounts_passwords_pam_faillock_deny_root" in c_r4.rules
    assert "accounts_password_pam_minlen" in c_r4.rules
    assert "accounts_password_pam_ocredit" in c_r4.rules
    assert "var_password_pam_ocredit" in c_r4.variables
    assert c_r4.variables["var_password_pam_ocredit"] == "1"


def test_controls_levels():
    controls_manager = ssg.controls.ControlsManager(controls_dir)
    controls_manager.load()

    # Default level is the lowest level
    c_1 = controls_manager.get_control("abcd-levels", "S1")
    assert c_1.level == "low"
    c_4 = controls_manager.get_control("abcd-levels", "S4")
    assert c_4.level == "low"

    # Explicit levels
    c_2 = controls_manager.get_control("abcd-levels", "S2")
    assert c_2.level == "low"

    c_3 = controls_manager.get_control("abcd-levels", "S3")
    assert c_3.level == "high"

    c_4a = controls_manager.get_control("abcd-levels", "S4.a")
    assert c_4a.level == "low"

    c_4a = controls_manager.get_control("abcd-levels", "S4.b")
    assert c_4a.level == "high"

    # just the essential controls
    low_controls = controls_manager.get_all_controls_of_level_at_least(
        "abcd-levels", "low")
    # essential and more advanced together
    high_controls = controls_manager.get_all_controls_of_level_at_least(
        "abcd-levels", "high")
    all_controls = controls_manager.get_all_controls("abcd-levels")

    assert len(high_controls) == len(all_controls)
    assert len(low_controls) <= len(high_controls)
    assert len(low_controls) == 4


def test_controls_load_product():
    ssg_root = \
            os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
    product_yaml = os.path.join(ssg_root, "rhel8", "product.yml")
    build_config_yaml = os.path.join(ssg_root, "build", "build_config.yml")
    env_yaml = open_environment(build_config_yaml, product_yaml)

    controls_manager = ssg.controls.ControlsManager(controls_dir, env_yaml)
    controls_manager.load()

    c_r1 = controls_manager.get_control("abcd", "R1")
    assert c_r1.title == "User session timeout"
    assert c_r1.description == "Remote user sessions must be closed after " \
        "a certain period of inactivity."
    assert c_r1.automated == "yes"
    assert "sshd_set_idle_timeout" in c_r1.rules
    assert "accounts_tmout" in c_r1.rules
    assert "var_accounts_tmout=10_min" not in c_r1.rules
    assert "var_accounts_tmout" in c_r1.variables
    assert c_r1.variables["var_accounts_tmout"] == "10_min"


def test_profile_resolution_separate():
    profile_resolution(ssg.build_yaml.ProfileWithSeparatePolicies, "abcd-low")


def test_profile_resolution_extends_separate():
    profile_resolution_extends(
        ssg.build_yaml.ProfileWithSeparatePolicies, "abcd-low", "abcd-high")


def test_profile_resolution_all_separate():
    profile_resolution_all(
        ssg.build_yaml.ProfileWithSeparatePolicies, "abcd-all")


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


def profile_resolution(cls, profile_low):
    ssg_root = \
            os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
    product_yaml = os.path.join(ssg_root, "rhel8", "product.yml")
    build_config_yaml = os.path.join(ssg_root, "build", "build_config.yml")
    env_yaml = open_environment(build_config_yaml, product_yaml)

    controls_manager = ssg.controls.ControlsManager(controls_dir, env_yaml)
    controls_manager.load()
    low_profile_path = os.path.join(profiles_dir, profile_low + ".profile")
    profile = cls.from_yaml(low_profile_path)
    all_profiles = {"abcd-low": profile}
    profile.resolve(all_profiles, controls_manager=controls_manager)

    # Profile 'abcd-low' selects controls R1, R2, R3 from 'abcd' policy,
    # which should add the following rules to the profile:
    assert "sshd_set_idle_timeout" in profile.selected
    assert "accounts_tmout" in profile.selected
    assert "configure_crypto_policy" in profile.selected
    assert "var_accounts_tmout" in profile.variables

    # The rule "security_patches_up_to_date" has been selected directly
    # by profile selections, not by using controls, so it should be in
    # the resolved profile as well.
    assert "security_patches_up_to_date" in profile.selected


def profile_resolution_extends(cls, profile_low, profile_high):
    ssg_root = \
            os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
    product_yaml = os.path.join(ssg_root, "rhel8", "product.yml")
    build_config_yaml = os.path.join(ssg_root, "build", "build_config.yml")
    env_yaml = open_environment(build_config_yaml, product_yaml)

    # tests ABCD High profile which is defined as an extension of ABCD Low
    controls_manager = ssg.controls.ControlsManager(controls_dir, env_yaml)
    controls_manager.load()

    low_profile_path = os.path.join(profiles_dir, profile_low + ".profile")
    low_profile = cls.from_yaml(low_profile_path)
    high_profile_path = os.path.join(profiles_dir, profile_high + ".profile")
    high_profile = cls.from_yaml(high_profile_path)
    all_profiles = {profile_low: low_profile, profile_high: high_profile}
    high_profile.resolve(all_profiles, controls_manager=controls_manager)

    # Profile 'abcd-high' selects controls R1, R2, R3 from 'abcd' policy,
    # which should add the following rules to the profile:
    assert "sshd_set_idle_timeout" in high_profile.selected
    assert "accounts_tmout" in high_profile.selected
    assert "configure_crypto_policy" in high_profile.selected
    assert "var_accounts_tmout" in high_profile.variables

    # The rule "security_patches_up_to_date" has been selected directly by the
    # abcd-low profile selections, not by using controls, so it should be
    # in the resolved profile as well.
    assert "security_patches_up_to_date" in high_profile.selected

    assert "accounts_passwords_pam_faillock_deny_root" in high_profile.selected
    assert "accounts_password_pam_minlen" in high_profile.selected
    assert "accounts_password_pam_ocredit" in high_profile.selected
    assert "var_password_pam_ocredit" in high_profile.variables
    assert high_profile.variables["var_password_pam_ocredit"] == "2"


def profile_resolution_all(cls, profile_all):
    ssg_root = \
            os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
    product_yaml = os.path.join(ssg_root, "rhel8", "product.yml")
    build_config_yaml = os.path.join(ssg_root, "build", "build_config.yml")
    env_yaml = open_environment(build_config_yaml, product_yaml)

    controls_manager = ssg.controls.ControlsManager(controls_dir, env_yaml)
    controls_manager.load()
    profile_path = os.path.join(profiles_dir, profile_all + ".profile")
    profile = cls.from_yaml(profile_path)
    all_profiles = {profile_all: profile}
    profile.resolve(all_profiles, controls_manager=controls_manager)

    # Profile 'abcd-all' selects all controls from 'abcd' policy,
    # which should add the following rules and variables to the profile:
    assert "sshd_set_idle_timeout" in profile.selected
    assert "accounts_tmout" in profile.selected
    assert "var_accounts_tmout" in profile.variables
    assert profile.variables["var_accounts_tmout"] == "10_min"
    assert "configure_crypto_policy" in profile.selected
    # Rule "systemd_target_multi_user" is only "related_rules"
    # therefore it should not appear in the resolved profile.
    assert "systemd_target_multi_user" not in profile.selected
    assert "accounts_passwords_pam_faillock_deny_root" in profile.selected
    assert "accounts_password_pam_minlen" in profile.selected
    assert "accounts_password_pam_ocredit" in profile.selected
    assert "var_password_pam_ocredit" in profile.variables
    assert profile.variables["var_password_pam_ocredit"] == "1"

    # The rule "security_patches_up_to_date" has been selected directly
    # by profile selections, not by using controls, so it should be in
    # the resolved profile as well.
    assert "security_patches_up_to_date" in profile.selected
