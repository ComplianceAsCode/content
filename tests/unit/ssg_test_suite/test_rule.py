import os
import pytest

from ssg_test_suite import rule
from tests.ssg_test_suite.rule import Scenario
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
    assert s.matches_platform({"cpe:/o:redhat:enterprise_linux:7"})
    assert not s.matches_platform({"cpe:/o:debian:debian:8"})

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
    assert len(s.script_params["remediation"]) == 1
    assert "all" in s.script_params["remediation"]
    assert len(s.script_params["variables"]) == 0
    assert s.matches_platform({"cpe:/o:redhat:enterprise_linux:7"})
    assert s.matches_platform({"cpe:/o:debian:debian:8"})
    s.override_profile("xccdf_org.ssgproject.content_profile_cis")
    assert "xccdf_org.ssgproject.content_profile_cis" in \
        s.script_params["profiles"]
