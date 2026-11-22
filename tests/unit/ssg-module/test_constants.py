import os
import subprocess
import sys


PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))


def _get_oscap_profile_prefix(vendor=None):
    env = os.environ.copy()
    env["PYTHONPATH"] = PROJECT_ROOT
    if vendor is None:
        env.pop("SSG_VENDOR", None)
    else:
        env["SSG_VENDOR"] = vendor
    return subprocess.check_output(
        [sys.executable, "-c", "from ssg.constants import OSCAP_PROFILE; print(OSCAP_PROFILE)"],
        env=env,
        text=True,
    ).strip()


def test_oscap_vendor_defaults_to_ssg_project():
    assert _get_oscap_profile_prefix() == "xccdf_org.ssgproject.content_profile_"


def test_oscap_vendor_can_be_configured():
    assert _get_oscap_profile_prefix("com.example") == "xccdf_com.example.content_profile_"
