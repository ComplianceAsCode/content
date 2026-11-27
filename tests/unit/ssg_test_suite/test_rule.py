import os

from tests.ssg_test_suite.rule import RuleChecker, RuleTestContent, Scenario
from ssg.constants import OSCAP_PROFILE_ALL_ID

DATADIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "data"))


def test_scenario():
    file_name = "correct.pass.sh"
    file_contents = open(os.path.join(DATADIR, file_name)).read()
    s = Scenario(file_name, file_contents)
    assert s.script == file_name
    assert s.contents == file_contents
    assert s.context == "pass"
    assert len(s.script_params["packages"]) == 2
    assert "sudo" in s.script_params["packages"]
    assert "authselect" in s.script_params["packages"]
    assert len(s.script_params["platform"]) == 2
    assert "multi_platform_rhel" in s.script_params["platform"]
    assert "Fedora" in s.script_params["platform"]
    assert len(s.script_params["profiles"]) == 1
    assert "xccdf_org.ssgproject.content_profile_cis" in \
        s.script_params["profiles"]
    assert OSCAP_PROFILE_ALL_ID not in s.script_params["profiles"]
    assert len(s.script_params["check"]) == 1
    assert "oval" in s.script_params["check"]
    assert len(s.script_params["remediation"]) == 1
    assert "none" in s.script_params["remediation"]
    assert len(s.script_params["variables"]) == 2
    assert "var_password_pam_remember=5" in s.script_params["variables"]
    assert "var_password_pam_remember_control_flag=requisite" in \
        s.script_params["variables"]
    assert len(s.script_params["templates"]) == 0
    assert s.matches_regex(r".*pass\.sh")
    assert s.matches_regex(r"^correct.*")
    assert not s.matches_regex(r".*fail\.sh")
    assert not s.matches_regex(r"^wrong")
    assert s.matches_platform("rhel10")
    assert not s.matches_platform("debian8")
    assert s.matches_check({"oval"})
    assert not s.matches_check({"sce"})
    assert not s.matches_check({"fancy_unsupported_language"})
    assert not s.matches_check({})


def test_scenario_defaults():
    file_name = "correct_defaults.pass.sh"
    file_contents = open(os.path.join(DATADIR, file_name)).read()
    s = Scenario(file_name, file_contents)
    assert s.script == file_name
    assert s.contents == file_contents
    assert s.context == "pass"
    assert len(s.script_params["profiles"]) == 1
    assert OSCAP_PROFILE_ALL_ID in s.script_params["profiles"]
    assert len(s.script_params["templates"]) == 0
    assert len(s.script_params["packages"]) == 0
    assert len(s.script_params["platform"]) == 1
    assert "multi_platform_all" in s.script_params["platform"]
    assert len(s.script_params["check"]) == 1
    assert "any" in s.script_params["check"]
    assert len(s.script_params["remediation"]) == 1
    assert "all" in s.script_params["remediation"]
    assert len(s.script_params["variables"]) == 0
    assert s.matches_platform("rhel10")
    assert s.matches_platform("debian12")
    s.override_profile("xccdf_org.ssgproject.content_profile_cis")
    assert "xccdf_org.ssgproject.content_profile_cis" in \
        s.script_params["profiles"]


class PackagelessTestEnv:
    """Stands in for a test environment, offering only the product ID that
    package replacement and the skip message read"""
    def __init__(self, product="rhel8"):
        self.product = product


def load_scenario(file_name):
    file_contents = open(os.path.join(DATADIR, file_name)).read()
    return Scenario(file_name, file_contents)


def test_drop_scenarios_needing():
    needs_packages = load_scenario("correct.pass.sh")
    needs_nothing = load_scenario("correct_defaults.pass.sh")
    checker = RuleChecker(PackagelessTestEnv())
    content = {"rule": RuleTestContent([needs_packages, needs_nothing], dict())}

    checker._drop_scenarios_needing(content, set())
    assert content["rule"].scenarios == [needs_packages, needs_nothing]

    checker._drop_scenarios_needing(content, {"vim"})
    assert content["rule"].scenarios == [needs_packages, needs_nothing]

    checker._drop_scenarios_needing(content, {"authselect"})
    assert content["rule"].scenarios == [needs_nothing]


def test_drop_scenarios_needing_renamed_package():
    """ A scenario asks for 'pam', which on Ubuntu means libpam-runtime """
    needs_pam = Scenario("pam.pass.sh", "#!/bin/bash\n# packages = pam\n")
    checker = RuleChecker(PackagelessTestEnv("ubuntu2404"))
    content = {"rule": RuleTestContent([needs_pam], dict())}

    checker._drop_scenarios_needing(content, {"pam"})
    assert content["rule"].scenarios == [needs_pam]

    checker._drop_scenarios_needing(content, {"libpam-runtime"})
    assert content["rule"].scenarios == []
