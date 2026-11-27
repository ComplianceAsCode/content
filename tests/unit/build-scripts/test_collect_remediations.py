import os
import sys

import ssg.build_remediations as remediation
import ssg.utils

sys.path.insert(
    0, os.path.join(os.path.dirname(__file__), "..", "..", "..", "build-scripts")
)
import collect_remediations as cr  # noqa: E402


def _write(path, contents):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        f.write(contents)


def _make_rule_dir(tmp_path):
    rule_dir = str(tmp_path / "rule")
    _write(os.path.join(rule_dir, "rule.yml"), "documentation_complete: true\n")
    return rule_dir


def test_find_remediation_candidates_static_precedes_templated(tmp_path):
    rule_dir = _make_rule_dir(tmp_path)
    static_fix = os.path.join(rule_dir, "bash", "shared.sh")
    _write(static_fix, "# platform = multi_platform_all\necho static\n")

    templates_dir = str(tmp_path / "fixes_from_templates")
    templated_fix = os.path.join(templates_dir, "bash", "test_rule.sh")
    _write(templated_fix, "# platform = multi_platform_all\necho templated\n")

    candidates = cr.find_remediation_candidates(
        templates_dir, rule_dir, "bash", "rhel9", "test_rule.sh")

    assert candidates == [static_fix, templated_fix]


def test_find_remediation_candidates_product_specific_precedes_shared(tmp_path):
    rule_dir = _make_rule_dir(tmp_path)
    product_fix = os.path.join(rule_dir, "bash", "rhel9.sh")
    shared_fix = os.path.join(rule_dir, "bash", "shared.sh")
    _write(product_fix, "# platform = multi_platform_rhel\necho rhel\n")
    _write(shared_fix, "# platform = multi_platform_all\necho shared\n")

    candidates = cr.find_remediation_candidates(
        str(tmp_path / "no_templates"), rule_dir, "bash", "rhel9", "test_rule.sh")

    assert candidates == [product_fix, shared_fix]


def test_find_remediation_candidates_only_templated(tmp_path):
    rule_dir = _make_rule_dir(tmp_path)
    templates_dir = str(tmp_path / "fixes_from_templates")
    templated_fix = os.path.join(templates_dir, "bash", "test_rule.sh")
    _write(templated_fix, "# platform = multi_platform_all\necho templated\n")

    candidates = cr.find_remediation_candidates(
        templates_dir, rule_dir, "bash", "rhel9", "test_rule.sh")

    assert candidates == [templated_fix]


def test_find_remediation_candidates_none(tmp_path):
    rule_dir = _make_rule_dir(tmp_path)

    candidates = cr.find_remediation_candidates(
        str(tmp_path / "no_templates"), rule_dir, "bash", "rhel9", "test_rule.sh")

    assert candidates == []


def _select_first_applicable(candidates, product):
    for candidate in candidates:
        _, config = remediation.parse_from_file_without_jinja(candidate)
        if ssg.utils.is_applicable_for_product(config["platform"], product):
            return candidate
    return None


def test_static_remediation_not_applicable_falls_back_to_templated(tmp_path):
    """
    A static remediation whose platform does not match the product being built
    must not shadow an applicable templated remediation.
    """
    rule_dir = _make_rule_dir(tmp_path)
    static_fix = os.path.join(rule_dir, "bash", "shared.sh")
    _write(static_fix, "# platform = SUSE Linux Enterprise 16\necho suse\n")

    templates_dir = str(tmp_path / "fixes_from_templates")
    templated_fix = os.path.join(templates_dir, "bash", "test_rule.sh")
    _write(templated_fix, "# platform = multi_platform_all\necho templated\n")

    candidates = cr.find_remediation_candidates(
        templates_dir, rule_dir, "bash", "rhel9", "test_rule.sh")

    assert _select_first_applicable(candidates, "rhel9") == templated_fix


def test_applicable_static_remediation_wins_over_templated(tmp_path):
    rule_dir = _make_rule_dir(tmp_path)
    static_fix = os.path.join(rule_dir, "bash", "shared.sh")
    _write(static_fix, "# platform = SUSE Linux Enterprise 16\necho suse\n")

    templates_dir = str(tmp_path / "fixes_from_templates")
    templated_fix = os.path.join(templates_dir, "bash", "test_rule.sh")
    _write(templated_fix, "# platform = multi_platform_all\necho templated\n")

    candidates = cr.find_remediation_candidates(
        templates_dir, rule_dir, "bash", "sle16", "test_rule.sh")

    assert _select_first_applicable(candidates, "sle16") == static_fix
