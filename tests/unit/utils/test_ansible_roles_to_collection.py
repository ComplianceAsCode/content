import sys
from pathlib import Path

import yaml

from utils.ansible_roles_to_collection import (
    COLLECTION_DESCRIPTION,
    COLLECTION_DEPENDENCIES,
    COLLECTIONS_TO_VENDOR,
    COLLECTION_ISSUES,
    COLLECTION_INSTALL_SERVER,
    COLLECTION_MIN_PYTHON_VERSION,
    COLLECTION_TARGETS,
    _make_vendored_module_self_contained,
    generate_collection_docs,
    generate_galaxy_yml,
    generate_runtime_yml,
    detect_modules_to_bundle,
    parse_args,
)
from ssg.constants import min_ansible_version


REPO_ROOT = Path(__file__).resolve().parents[3]


def test_generate_collection_docs(tmp_path):
    issues = "https://example.test/issues"
    installation_server = "https://cloud.example.test/api/automation-hub/"

    generate_collection_docs(
        tmp_path,
        "redhat",
        "rhel_hardening_roles",
        "0.1.82",
        ["rhel10_stig", "rhel9_cis"],
        issues,
        installation_server,
        "Red Hat",
        "Custom-License",
    )

    readme = (tmp_path / "README.md").read_text()
    assert "redhat.rhel_hardening_roles.rhel10_stig" in readme
    assert f"--server {installation_server}" in readme
    assert "redhat-rhel_hardening_roles-0.1.82.tar.gz" in readme
    assert f"ansible-core >= {min_ansible_version}" in readme
    assert f"Python >= {COLLECTION_MIN_PYTHON_VERSION}" in readme
    assert "ansible.posix >= 2.2.0" in readme
    assert "https://github.com/ComplianceAsCode/content/releases" in readme
    assert "Create issue button" in readme
    assert "top right corner of Automation Hub" in readme
    assert f"[collection issue tracker]({issues})" in readme
    assert "Custom-License" in readme
    assert "Red Hat" in readme
    assert (tmp_path / "CHANGELOG.md").read_text().startswith("# Changelog\n")
    assert (tmp_path / "changelogs" / "README.md").is_file()
    assert (tmp_path / "LICENSE").read_text() == (REPO_ROOT / "LICENSE").read_text()


def test_generate_galaxy_yml_uses_generic_defaults(tmp_path):
    generate_galaxy_yml(tmp_path, "redhatofficial", "rhel_hardening_roles", "0.1.82")

    metadata = yaml.safe_load((tmp_path / "galaxy.yml").read_text())
    assert metadata["description"] == COLLECTION_DESCRIPTION
    assert metadata["issues"] == COLLECTION_ISSUES
    assert "documentation" not in metadata


def test_generate_galaxy_yml_accepts_automation_hub_metadata(tmp_path):
    documentation = "https://docs.example.test/rhel10"
    issues = "https://redhat.example.test/issues"

    generate_galaxy_yml(
        tmp_path,
        "redhat",
        "rhel_hardening_roles",
        "0.1.82",
        description="RHEL hardening roles",
        documentation=documentation,
        issues=issues,
        authors=["Red Hat"],
        licenses=["BSD-3-Clause"],
    )

    metadata = yaml.safe_load((tmp_path / "galaxy.yml").read_text())
    assert metadata["description"] == "RHEL hardening roles"
    assert metadata["documentation"] == documentation
    assert metadata["issues"] == issues
    assert metadata["authors"] == ["Red Hat"]
    assert metadata["license"] == ["BSD-3-Clause"]
    assert metadata["dependencies"] == COLLECTION_DEPENDENCIES


def test_generate_runtime_yml_uses_collection_minimum(tmp_path):
    (tmp_path / "meta").mkdir()
    generate_runtime_yml(tmp_path)

    runtime = yaml.safe_load((tmp_path / "meta" / "runtime.yml").read_text())
    # Certification tooling expects a full X.Y.Z lower bound (e.g. >=2.16.0), so the
    # X.Y min_ansible_version is padded with a patch level in the collection runtime.
    padded_version = min_ansible_version + ".0" * (2 - min_ansible_version.count("."))
    assert runtime["requires_ansible"] == f">={padded_version}"


def test_ansible_posix_is_not_vendored(tmp_path):
    tasks = tmp_path / "tasks"
    tasks.mkdir()
    (tasks / "main.yml").write_text(
        "- name: Use external collections\n"
        "  ansible.posix.sysctl:\n"
        "    name: kernel.pid_max\n"
        "    value: 4194304\n"
        "- name: Use vendored collection\n"
        "  community.general.ini_file:\n"
        "    path: /etc/example\n"
    )

    detected = detect_modules_to_bundle([tmp_path], COLLECTIONS_TO_VENDOR)

    assert detected == {"community.general": ["ini_file"]}


def test_vendored_module_inlines_external_documentation_fragment(tmp_path):
    module_path = tmp_path / "ini_file.py"
    module_path.write_text(
        "DOCUMENTATION = r'''\n"
        "attributes:\n"
        "  - files\n"
        "  - community.general.attributes\n"
        "  check_mode:\n"
        "    support: full\n"
        "  diff_mode:\n"
        "    support: full\n"
        "'''\n"
    )

    _make_vendored_module_self_contained("ini_file", module_path)

    content = module_path.read_text()
    assert "community.general.attributes" not in content
    assert "Can run in C(check_mode)" in content
    assert "Returns details on what has changed" in content


def test_generic_installation_server_is_stable():
    assert COLLECTION_INSTALL_SERVER == "https://galaxy.ansible.com/"


def test_hub_installation_server_uses_console_redhat_com():
    # cloud.redhat.com is deprecated; Automation Hub is served from console.redhat.com.
    assert (
        COLLECTION_TARGETS["hub"]["installation_server"]
        == "https://console.redhat.com/api/automation-hub/"
    )


def test_parse_args_uses_galaxy_target_by_default(monkeypatch):
    monkeypatch.setattr(
        sys,
        "argv",
        ["ansible_roles_to_collection.py", "--roles-dir", "roles", "--output-dir", "output"],
    )

    args = parse_args()

    assert args.target == "galaxy"
    assert args.namespace == COLLECTION_TARGETS["galaxy"]["namespace"]
    assert args.installation_server == COLLECTION_TARGETS["galaxy"]["installation_server"]


def test_parse_args_uses_hub_target_metadata(monkeypatch):
    monkeypatch.setattr(
        sys,
        "argv",
        [
            "ansible_roles_to_collection.py",
            "--roles-dir",
            "roles",
            "--output-dir",
            "output",
            "--target",
            "hub",
        ],
    )

    args = parse_args()

    assert args.namespace == "redhat"
    assert args.author == "Red Hat"
    assert args.documentation == COLLECTION_TARGETS["hub"]["documentation"]
    assert args.issues == COLLECTION_TARGETS["hub"]["issues"]
    assert args.installation_server == COLLECTION_TARGETS["hub"]["installation_server"]
