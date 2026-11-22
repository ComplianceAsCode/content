import os
import subprocess
import sys


PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))


def _get_oscap_constants(vendor=None):
    env = os.environ.copy()
    env["PYTHONPATH"] = PROJECT_ROOT
    if vendor is None:
        env.pop("SSG_VENDOR", None)
    else:
        env["SSG_VENDOR"] = vendor
    return subprocess.check_output(
        [
            sys.executable,
            "-c",
            (
                "from ssg.constants import (OSCAP_BENCHMARK, OSCAP_GROUP, OSCAP_PROFILE, "
                "OSCAP_RULE, OSCAP_VALUE); "
                "print(OSCAP_BENCHMARK, OSCAP_PROFILE, OSCAP_GROUP, OSCAP_RULE, OSCAP_VALUE, "
                "sep='\\n')"
            ),
        ],
        env=env,
        text=True,
    ).splitlines()


def test_oscap_vendor_defaults_to_ssg_project():
    assert _get_oscap_constants() == [
        "xccdf_org.ssgproject.content_benchmark_",
        "xccdf_org.ssgproject.content_profile_",
        "xccdf_org.ssgproject.content_group_",
        "xccdf_org.ssgproject.content_rule_",
        "xccdf_org.ssgproject.content_value_",
    ]


def test_oscap_vendor_can_be_configured():
    assert _get_oscap_constants("com.example") == [
        "xccdf_com.example.content_benchmark_",
        "xccdf_com.example.content_profile_",
        "xccdf_com.example.content_group_",
        "xccdf_com.example.content_rule_",
        "xccdf_com.example.content_value_",
    ]
