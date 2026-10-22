import os
import subprocess

import pytest

from tests.ssg_test_suite import common
from tests.ssg_test_suite.log import LogHelper

RHEL8_CPE = 'CPE_NAME="cpe:/o:redhat:enterprise_linux:8::baseos"'
OL7_CPE = 'CPE_NAME="cpe:/o:oracle:linux:7:9:server"'


class RecordingTestEnv:
    """Stands in for a test environment whose repositories lack the packages
    named in `unavailable` and offer the rest, of which the ones in `broken`
    fail to install. Unreachable repositories fail every install and every
    query. It keeps every install command it was given"""
    def __init__(self, unavailable=(), broken=(), reachable=True, cpe=RHEL8_CPE):
        self.unavailable = set(unavailable)
        self.broken = set(broken)
        self.reachable = reachable
        self.cpe = cpe
        self.commands = []

    def execute_ssh_command(self, command, log_file, error_msg_template=None):
        if "CPE_NAME" in command:
            return self.cpe
        if not self.reachable:
            raise RuntimeError("Failed to download metadata")
        words = command.split()
        if "repoquery" in words:
            package = words[-1]
            return "" if package in self.unavailable else package + "-1.0-1.el8.noarch\n"
        self.commands.append(command)
        failing = set(words) & (self.unavailable | self.broken)
        if failing:
            raise RuntimeError("Couldn't install %s" % ",".join(sorted(failing)))
        return ""


@pytest.fixture(autouse=True)
def log_dir(tmp_path):
    previous = LogHelper.LOG_DIR
    LogHelper.LOG_DIR = str(tmp_path)
    yield
    LogHelper.LOG_DIR = previous


def test_install_packages():
    test_env = RecordingTestEnv()
    assert common.install_packages(test_env, {"sudo", "pam"}) == set()
    assert len(test_env.commands) == 1


def test_install_packages_unavailable():
    test_env = RecordingTestEnv({"authselect"})
    assert common.install_packages(
        test_env, {"authselect", "pam"}) == {"authselect"}
    assert "yum install -y pam" in test_env.commands


def test_install_packages_all_unavailable():
    test_env = RecordingTestEnv({"authselect", "aide"})
    assert common.install_packages(
        test_env, {"authselect", "aide"}) == {"authselect", "aide"}


def test_install_packages_offered_but_failing():
    test_env = RecordingTestEnv({"authselect"}, broken={"pam"})
    with pytest.raises(RuntimeError, match="pam"):
        common.install_packages(test_env, {"authselect", "pam"})


def test_install_packages_unreachable_repositories():
    test_env = RecordingTestEnv(reachable=False)
    with pytest.raises(RuntimeError):
        common.install_packages(test_env, {"authselect", "pam"})


def test_install_packages_without_query_command():
    test_env = RecordingTestEnv({"authselect"}, cpe=OL7_CPE)
    with pytest.raises(RuntimeError, match="authselect"):
        common.install_packages(test_env, {"authselect", "pam"})


FAKE_APT_CACHE = r"""#!/bin/sh
# Answers like apt-cache on a Debian 12 system whose indexes are present
# unless NO_INDEXES is set. dconf is only mentioned by dconf-cli.
if [ "$#" -eq 1 ]; then
    echo "Package files:"
    if [ -z "$NO_INDEXES" ]; then
        echo " 500 http://deb.debian.org/debian bookworm/main amd64 Packages"
    fi
    exit 0
fi
case "$2" in
    dconf)
        printf 'dconf:\n  Installed: (none)\n  Candidate: (none)\n  Version table:\n' ;;
    dconf-cli)
        printf 'dconf-cli:\n  Installed: (none)\n  Candidate: 0.40.0-4\n  Version table:\n' ;;
esac
"""


def run_apt_query(tmp_path, platform, package, no_indexes=False):
    fake = tmp_path / "apt-cache"
    fake.write_text(FAKE_APT_CACHE)
    fake.chmod(0o755)
    env = dict(os.environ, PATH="%s:%s" % (tmp_path, os.environ["PATH"]))
    if no_indexes:
        env["NO_INDEXES"] = "1"
    command = common.QUERY_COMMANDS[platform].format(package=package)
    return subprocess.run(["sh", "-c", command], env=env,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                          universal_newlines=True)


@pytest.mark.parametrize("platform", ["debian", "ubuntu"])
def test_apt_query_skips_a_name_without_candidate(tmp_path, platform):
    result = run_apt_query(tmp_path, platform, "dconf")
    assert result.returncode == 0
    assert result.stdout.strip() == ""


@pytest.mark.parametrize("platform", ["debian", "ubuntu"])
def test_apt_query_reports_a_package_with_candidate(tmp_path, platform):
    result = run_apt_query(tmp_path, platform, "dconf-cli")
    assert result.returncode == 0
    assert "Candidate: 0.40.0-4" in result.stdout


@pytest.mark.parametrize("platform", ["debian", "ubuntu"])
def test_apt_query_fails_without_indexes(tmp_path, platform):
    result = run_apt_query(tmp_path, platform, "dconf-cli", no_indexes=True)
    assert result.returncode != 0
