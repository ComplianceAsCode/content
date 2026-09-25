from pathlib import Path

import yaml

from utils.ansible_roles_to_collection import (
    COLLECTION_DESCRIPTION,
    COLLECTION_ISSUES,
    COLLECTION_INSTALL_SERVER,
    COLLECTION_MIN_ANSIBLE_VERSION,
    COLLECTION_MIN_PYTHON_VERSION,
    generate_collection_docs,
    generate_galaxy_yml,
    generate_runtime_yml,
)


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
    assert f"ansible-core >= {COLLECTION_MIN_ANSIBLE_VERSION}" in readme
    assert f"Python >= {COLLECTION_MIN_PYTHON_VERSION}" in readme
    assert f"Report issues at {issues}." in readme
    assert "Custom-License" in readme
    assert "Red Hat" in readme
    assert (tmp_path / "CHANGELOG.md").read_text().startswith("# Changelog\n")
    assert (tmp_path / "changelogs" / "README.md").is_file()
    assert (tmp_path / "LICENSE").read_text() == Path("LICENSE").read_text()


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


def test_generate_runtime_yml_uses_collection_minimum(tmp_path):
    (tmp_path / "meta").mkdir()
    generate_runtime_yml(tmp_path)

    runtime = yaml.safe_load((tmp_path / "meta" / "runtime.yml").read_text())
    assert runtime["requires_ansible"] == f">={COLLECTION_MIN_ANSIBLE_VERSION}"


def test_generic_installation_server_is_stable():
    assert COLLECTION_INSTALL_SERVER == "https://galaxy.ansible.com/"
