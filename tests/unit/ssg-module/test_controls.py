import pytest
import logging
import os

import ssg.controls
import ssg.build_yaml

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
    # we haven't specified product but this rule should appear
    # only if product is rhel9
    assert "cockpit_session_timeout" not in c_r1.rules

    c_r2 = controls_manager.get_control("abcd", "R2")
    assert c_r2.automated == "no"
    assert c_r2.note == "This is individual depending on the system " \
        "workload therefore needs to be audited manually."
    assert len(c_r2.rules) == 0

    c_r4 = controls_manager.get_control("abcd", "R4")
    assert len(c_r4.rules) == 3
    assert "accounts_passwords_pam_faillock_deny_root" in c_r4.rules
    assert "accounts_password_pam_minlen" in c_r4.rules
    assert "accounts_password_pam_ocredit" in c_r4.rules
    assert "var_password_pam_ocredit" in c_r4.variables
    assert c_r4.variables["var_password_pam_ocredit"] == "1"
    #logging.info(c.rules)

def test_controls_load_product():
    env_yaml = {"product": "rhel9"}
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
    # The rule cockpit_session_timeout is guarded by Jinja macro
    # that allows it only on rhel9 product.
    assert "cockpit_session_timeout" in c_r1.rules

def test_profile_resolution():
    env_yaml = {"product": "rhel9"}
    controls_manager = ssg.controls.ControlsManager(controls_dir, env_yaml)
    controls_manager.load()
    high_profile_path = os.path.join(profiles_dir, "abcd-high.profile")
    profile = ssg.build_yaml.ResolvableProfile.from_yaml(high_profile_path)
    all_profiles = {"abcd-high": profile}
    profile.resolve(all_profiles, controls_manager=controls_manager)

    # Profile 'abcd-high' selects controls R1, R2, R3 from 'abcd' policy,
    # which should add the following rules to the profile:
    assert "sshd_set_idle_timeout" in profile.selected
    assert "accounts_tmout" in profile.selected
    assert "cockpit_session_timeout" in profile.selected
    assert "var_accounts_tmout" in profile.variables

    # The rule "security_patches_uptodate" has been selected directly by profile
    # selections, not by using controls, so it should be in the resolved profile
    # as well.
    assert "security_patches_uptodate" in profile.selected
