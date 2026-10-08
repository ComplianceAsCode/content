import os
import subprocess

import pytest

import ssg.jinja


@pytest.fixture
def pwquality_helper(tmp_path):
    """Run the actual helper with its files and PAM command isolated."""
    profile_dir = tmp_path / "pam-configs"
    profile_dir.mkdir()
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    pam_auth_update = bin_dir / "pam-auth-update"
    pam_auth_update.write_text("#!/bin/sh\nexit 0\n")
    pam_auth_update.chmod(0o755)

    macros = ssg.jinja.load_macros()
    script = str(macros["bash_pam_pwquality_enable"]()).replace(
        "/usr/share/pam-configs", str(profile_dir))
    env = dict(os.environ, PATH=str(bin_dir) + os.pathsep + os.environ["PATH"])

    def run_helper():
        subprocess.run(["bash", "-eu"], input=script, text=True, env=env, check=True)

    return profile_dir / "cac_pwquality", run_helper


def test_new_profile_preserves_retry_requirement(pwquality_helper):
    profile, run_helper = pwquality_helper
    run_helper()

    assert "pam_pwquality.so retry=3" in profile.read_text()
    assert profile.stat().st_mode & 0o777 == 0o644

    original = profile.read_bytes()
    run_helper()
    assert profile.read_bytes() == original


def test_existing_profile_preserves_stricter_settings(pwquality_helper):
    profile, run_helper = pwquality_helper
    original = "Password:\n    requisite pam_pwquality.so retry=1 enforce_for_root\n"
    profile.write_text(original)
    run_helper()

    assert profile.read_text() == original
