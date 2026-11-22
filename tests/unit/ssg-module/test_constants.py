import os
import subprocess
import sys


PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))


def _get_oscap_vendor_and_profile(vendor=None):
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
            "from ssg.constants import OSCAP_PROFILE, OSCAP_VENDOR; "
            "print(OSCAP_VENDOR, OSCAP_PROFILE, sep='\\n')",
        ],
        env=env,
        text=True,
    ).splitlines()


def test_oscap_vendor():
    for vendor in (None, "com.example"):
        expected_vendor = vendor or "org.ssgproject"
        assert _get_oscap_vendor_and_profile(vendor) == [
            expected_vendor,
            "xccdf_%s.content_profile_" % expected_vendor,
        ]
