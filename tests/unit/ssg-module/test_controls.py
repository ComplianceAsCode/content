import pytest
import os
import sys

import ssg.controls
import ssg.build_yaml
from ssg.environment import open_environment

ssg_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
data_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "data"))
controls_dir = os.path.join(data_dir, "controls_dir")
profiles_dir = os.path.join(data_dir, "profiles_dir")


def assert_control_confirms_to_standard(controls_manager, profile):
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
    assert "R4.a" in c_r4.controls
    assert "R4.b" in c_r4.controls
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


@pytest.fixture
def env_yaml():
    product_yaml = os.path.join(ssg_root, "products", "rhel8", "product.yml")
    build_config_yaml = os.path.join(ssg_root, "build", "build_config.yml")
    env_yaml = open_environment(build_config_yaml, product_yaml)
    return env_yaml


@pytest.fixture
def controls_manager(env_yaml):
    controls_manager = ssg.controls.ControlsManager(controls_dir, env_yaml)
    controls_manager.load()
    return controls_manager


@pytest.fixture
def compiled_controls_dir_py2(tmpdir):
    return str(tmpdir)


@pytest.fixture
def compiled_controls_dir_py3(tmp_path):
    return tmp_path


@pytest.fixture
def compiled_controls_manager(env_yaml, controls_manager,compiled_controls_dir_py2):
    controls_manager.save_everything(compiled_controls_dir_py2)
    controls_manager = ssg.controls.ControlsManager(compiled_controls_dir_py2, env_yaml)
    controls_manager.load()
    return controls_manager


def _load_test(controls_manager, profile):
    assert_control_confirms_to_standard(controls_manager, profile)


def test_controls_load(controls_manager):
    _load_test(controls_manager, "abcd")


@pytest.mark.skipif(sys.version_info[0] < 3, reason="requires python3 or higher")
def test_controls_invalid_rules(env_yaml):
    existing_rules = {"accounts_tmout", "configure_crypto_policy"}
    controls_manager = ssg.controls.ControlsManager(
        controls_dir, env_yaml, existing_rules)
    with pytest.raises(ValueError) as exc:
        controls_manager.load()
    assert str(exc.value) == \
        "Control abcd:R1 contains nonexisting rule(s) sshd_set_idle_timeout"


@pytest.mark.skipif(sys.version_info[0] < 3, reason="requires python3 or higher")
def test_controls_levels(controls_manager):
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


def test_controls_load_product(controls_manager):
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


def test_profile_resolution_inline(env_yaml, controls_manager):
    profile_resolution(
        env_yaml, controls_manager, ssg.build_yaml.ProfileWithInlinePolicies, "abcd-low-inline")


def test_profile_resolution_extends_inline(env_yaml, controls_manager):
    profile_resolution_extends(
        env_yaml, controls_manager,
        ssg.build_yaml.ProfileWithInlinePolicies,
        "abcd-low-inline", "abcd-high-inline")


def test_profile_resolution_all_inline(env_yaml, controls_manager):
    profile_resolution_all(
        env_yaml, controls_manager, ssg.build_yaml.ProfileWithInlinePolicies, "abcd-all-inline")


class DictContainingAnyRule(dict):
    def __getitem__(self, key):
        rule = ssg.build_yaml.Rule(key)
        rule.product = "all"
        return rule

    def __contains__(self, rid):
        return True


def profile_resolution(env_yaml, controls_manager, cls, profile_low):
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


def profile_resolution_extends(env_yaml, controls_manager, cls, profile_low, profile_high):
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


def profile_resolution_all(env_yaml, controls_manager, cls, profile_all):
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


def test_load_control_from_folder(controls_manager):
    _load_test(controls_manager, "qrst")


def test_load_control_from_folder_and_file(controls_manager):
    _load_test(controls_manager, "jklm")


def test_load_compiled_control_from_folder_and_file(compiled_controls_dir_py2, compiled_controls_manager):
    _load_test(compiled_controls_manager, "jklm")


def test_load_control_from_specific_folder_and_file(controls_manager):
    _load_test(controls_manager, "nopq")


@pytest.fixture
def minimal_empty_controls():
    return [dict(title="control", id="c", rules=["a"])]


@pytest.fixture
def one_simple_subcontrol():
    return dict(title="subcontrol", id="s", rules=["b"])


def test_policy_parse_from_dict(minimal_empty_controls):
    policy = ssg.controls.Policy("")
    controls = policy.save_controls_tree(minimal_empty_controls)
    controls = policy.controls
    assert len(controls) == 1
    control = controls[0]
    assert control.title == "control"


def test_policy_fail_parse_from_incomplete_dict(minimal_empty_controls):
    incomplete_controls = minimal_empty_controls
    incomplete_controls[0]["controls"] = [dict(title="nested")]

    policy = ssg.controls.Policy("")

    with pytest.raises(RuntimeError, match="id"):
        policy.save_controls_tree(incomplete_controls)


def order_by_attribute(items, attribute, ordering):
    items_by_attribute = {getattr(i, attribute): i for i in items}
    return [items_by_attribute[val] for val in ordering]


def test_policy_parse_from_nested(minimal_empty_controls, one_simple_subcontrol):
    nested_controls = minimal_empty_controls
    nested_controls[0]["controls"] = [one_simple_subcontrol]

    policy = ssg.controls.Policy("P")
    controls = policy.save_controls_tree(minimal_empty_controls)
    controls = policy.controls
    assert len(controls) == 2
    control, subcontrol = order_by_attribute(controls, "id", ("c", "s"))
    assert control.title == "control"
    assert control.selections == ["a"]
    assert subcontrol.title == "subcontrol"
    assert subcontrol.selections == ["b"]

    controls_manager = ssg.controls.ControlsManager("", dict())
    controls_manager.policies[policy.id] = policy

    controls_manager.resolve_controls()
    control = policy.get_control("c")
    assert control.selections == ["a", "b"]


def test_manager_removes_rules():
    control_dict = dict(id="top", rules=["one", "two", "three", "!four", "!five"])

    policy = ssg.controls.Policy("")
    policy.save_controls_tree([control_dict])
    policy.id = "P"

    controls_manager = ssg.controls.ControlsManager("", dict())
    controls_manager.policies[policy.id] = policy

    control = controls_manager.get_control("P", "top")
    assert len(control.selections) == 5

    controls_manager.remove_selections_not_known(["one", "four"])
    control = controls_manager.get_control("P", "top")
    assert len(control.selections) == 2
    assert "one" in control.selections
    assert "!four" in control.selections

    controls_manager.remove_selections_not_known([])
    control = controls_manager.get_control("P", "top")
    assert len(control.selections) == 0


def test_policy_parse_from_nested():
    top_control_dict = dict(id="top", controls=["nested-1"])
    first_nested_dict = dict(id="nested-1", controls=["nested-2"], rules="Y")
    second_nested_dict = dict(id="nested-2", rules=["X"])

    policy = ssg.controls.Policy("")
    policy.id = "P"

    controls_manager = ssg.controls.ControlsManager("", dict())
    controls_manager.policies[policy.id] = policy

    controls = policy.save_controls_tree([top_control_dict, second_nested_dict, first_nested_dict])
    controls_manager.resolve_controls()
    control = policy.get_control("top")
    assert "Y" in control.selections
    assert "X" in control.selections


def test_policy_parse_from_ours_and_foreign():
    main_control_dict = dict(id="top", controls=["foreign:top", "ours", "P:ours_qualified"])
    main_subcontrol_dicts = [dict(id="ours", rules=["ours"]), dict(id="ours_qualified", rules=["really_ours"])]
    foreign_control_dict = dict(id="top", rules=["foreign"])

    main_policy = ssg.controls.Policy("")
    main_policy.id = "P"
    main_policy.save_controls_tree([main_control_dict] + main_subcontrol_dicts)

    foreign_policy = ssg.controls.Policy("")
    foreign_policy.id = "foreign"
    foreign_policy.save_controls_tree([foreign_control_dict])

    controls_manager = ssg.controls.ControlsManager("", dict())
    controls_manager.policies[main_policy.id] = main_policy
    controls_manager.policies[foreign_policy.id] = foreign_policy

    controls_manager.resolve_controls()
    control = controls_manager.get_control("P", "top")
    assert "ours" in control.selections
    assert "really_ours" in control.selections
    assert "foreign" in control.selections


def test_policy_parse_from_referenced(minimal_empty_controls, one_simple_subcontrol):
    nested_controls = minimal_empty_controls
    nested_controls[0]["controls"] = ["s"]
    nested_controls.append(one_simple_subcontrol)

    policy = ssg.controls.Policy("")
    policy.id = "P"
    controls = policy.save_controls_tree(minimal_empty_controls)
    controls = policy.controls
    assert len(controls) == 2
    control, subcontrol = order_by_attribute(controls, "id", ("c", "s"))
    assert control.title == "control"
    assert control.controls == ["s"]
    assert subcontrol.title == "subcontrol"


def test_control_with_bad_key():
    control = {'id': 'abcd', 'badval': 'should not be here', }
    control_obj = None
    try:
        control_obj = ssg.controls.Control.from_control_dict(control)
    except ValueError as e:
        assert type(e) is ValueError
    assert control_obj is None


def test_control_with_bad_level():
    control = {'id': 'abcd', 'levels': 'medium', }
    control_obj = None
    try:
        control_obj = ssg.controls.Control.from_control_dict(control)
    except ValueError as e:
        assert type(e) is ValueError
    assert control_obj is None


def test_validating_policy_levels(env_yaml):
    c1_path = os.path.join(data_dir, "policy_with_different_than_implicit_default_level.yml")
    c2_path = os.path.join(data_dir, "policy_with_invalid_level.yml")
    for policy_path in [c1_path, c2_path]:
        policy = ssg.controls.Policy(policy_path, env_yaml)
        with pytest.raises(ValueError):
            policy.load()


