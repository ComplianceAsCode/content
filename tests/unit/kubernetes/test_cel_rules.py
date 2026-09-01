"""Unit tests for CEL rules (applications/**/cel/shared.yml).

Every CEL rule must ship semantic unit-test fixtures in <rule-dir>/cel/tests/
(a list of {name, expect, inputs} cases, optionally wrapped with provenance —
generate them with `celctl cac scaffold <rule-dir> --from-cluster`).

The fixtures are evaluated through celctl, which uses cel-go — the same engine
and environment (parseJSON/parseYAML, scanner binding semantics) as the
Compliance Operator scanner — so a rule that passes here behaves the same way
in the operator. celctl ships in the compliance-operator repo (cmd/celctl, merged in
https://github.com/ComplianceAsCode/compliance-operator/pull/1306).

celctl is located via the CELCTL environment variable, then PATH. When absent,
the evaluation tests are skipped (fixture-presence policy checks still run),
so contributors without Go are not blocked; CI installs celctl with:

    go install github.com/ComplianceAsCode/compliance-operator/cmd/celctl@master

(pin a release tag instead of @master once a compliance-operator release ships
cmd/celctl)
"""

import glob
import os
import shutil
import subprocess

import pytest
import yaml

SSG_ROOT = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..", ".."))
KNOWN_BROKEN_FILE = os.path.join(
    os.path.dirname(__file__), "known_broken_cel_rules.yml")


def _celctl():
    exe = os.environ.get("CELCTL") or shutil.which("celctl")
    if exe and os.path.isfile(exe) and os.access(exe, os.X_OK):
        return exe
    return None


def _known_broken():
    if not os.path.exists(KNOWN_BROKEN_FILE):
        return {}
    with open(KNOWN_BROKEN_FILE) as f:
        return yaml.safe_load(f) or {}


def _cel_rule_dirs():
    pattern = os.path.join(SSG_ROOT, "applications", "**", "cel", "shared.yml")
    return sorted(
        os.path.dirname(os.path.dirname(p))
        for p in glob.glob(pattern, recursive=True))


def _fixture_files(rule_dir):
    tests_dir = os.path.join(rule_dir, "cel", "tests")
    return sorted(
        p for ext in ("yaml", "yml", "json")
        for p in glob.glob(os.path.join(tests_dir, "*.%s" % ext)))


def _load_cases(path):
    with open(path) as f:
        doc = yaml.safe_load(f)
    if isinstance(doc, dict):
        return doc.get("cases") or [], doc.get("provenance")
    return doc or [], None


def _rule_id(rule_dir):
    return os.path.basename(rule_dir)


CEL_RULE_DIRS = _cel_rule_dirs()
KNOWN_BROKEN = _known_broken()


def test_cel_rules_discovered():
    assert CEL_RULE_DIRS, "no CEL rules found under applications/"


@pytest.mark.parametrize(
    "rule_dir", CEL_RULE_DIRS, ids=[_rule_id(d) for d in CEL_RULE_DIRS])
def test_cel_rule_has_fixtures(rule_dir):
    """Every CEL rule ships fixtures with at least one compliant and one
    non-compliant case, unless allowlisted in known_broken_cel_rules.yml."""
    rule = _rule_id(rule_dir)
    if rule in KNOWN_BROKEN:
        pytest.skip("known broken: %s" % KNOWN_BROKEN[rule].get("reason", ""))
    files = _fixture_files(rule_dir)
    assert files, (
        "CEL rule %s has no cel/tests fixtures; generate them with "
        "`celctl cac scaffold %s --from-cluster` and fill in the cases"
        % (rule, os.path.relpath(rule_dir, SSG_ROOT)))
    expects = []
    for path in files:
        cases, _ = _load_cases(path)
        assert cases, "%s contains no cases" % path
        for case in cases:
            assert "expect" in case and "inputs" in case, (
                "%s: each case needs name/expect/inputs" % path)
            expects.append(bool(case["expect"]))
    assert True in expects and False in expects, (
        "CEL rule %s fixtures must cover both a compliant (expect: true) and "
        "a non-compliant (expect: false) case" % rule)


@pytest.mark.parametrize(
    "rule_dir", CEL_RULE_DIRS, ids=[_rule_id(d) for d in CEL_RULE_DIRS])
def test_cel_rule_lint(rule_dir):
    """The expression compiles and list inputs are iterated via .items."""
    rule = _rule_id(rule_dir)
    if rule in KNOWN_BROKEN:
        pytest.skip("known broken: %s" % KNOWN_BROKEN[rule].get("reason", ""))
    celctl = _celctl()
    if not celctl:
        pytest.skip("celctl not found (set CELCTL or add it to PATH)")
    result = subprocess.run(
        [celctl, "cac", "lint", rule_dir],
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    assert result.returncode == 0, (
        "celctl cac lint %s failed:\n%s" % (rule, result.stdout))


@pytest.mark.parametrize(
    "rule_dir", CEL_RULE_DIRS, ids=[_rule_id(d) for d in CEL_RULE_DIRS])
def test_cel_rule_fixtures_evaluate(rule_dir):
    """Every fixture case evaluates to its expected result under cel-go."""
    rule = _rule_id(rule_dir)
    if rule in KNOWN_BROKEN:
        pytest.skip("known broken: %s" % KNOWN_BROKEN[rule].get("reason", ""))
    if not _fixture_files(rule_dir):
        pytest.skip("no fixtures (reported by test_cel_rule_has_fixtures)")
    celctl = _celctl()
    if not celctl:
        pytest.skip("celctl not found (set CELCTL or add it to PATH)")
    result = subprocess.run(
        [celctl, "cac", "test", rule_dir],
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    assert result.returncode == 0, (
        "celctl cac test %s failed:\n%s" % (rule, result.stdout))


@pytest.mark.parametrize(
    "rule_dir", CEL_RULE_DIRS, ids=[_rule_id(d) for d in CEL_RULE_DIRS])
def test_cel_rule_fixture_provenance(rule_dir):
    """Fixtures should record provenance (where the data shapes came from).

    Provenance guards against hand-invented resource shapes: schemas change
    across versions (e.g. HyperConverged featureGates is an object on v1beta1
    but an array on v1, and nonRoot was removed in 4.18+).
    """
    rule = _rule_id(rule_dir)
    if rule in KNOWN_BROKEN:
        pytest.skip("known broken: %s" % KNOWN_BROKEN[rule].get("reason", ""))
    files = _fixture_files(rule_dir)
    if not files:
        pytest.skip("no fixtures (reported by test_cel_rule_has_fixtures)")
    for path in files:
        _, provenance = _load_cases(path)
        assert provenance, (
            "%s lacks a provenance block; regenerate with "
            "`celctl cac scaffold --from-cluster` (records fetch date and "
            "OpenShift/Kubernetes versions - versions only, nothing "
            "cluster-identifiable)" % os.path.relpath(path, SSG_ROOT))


def test_known_broken_entries_are_real_rules():
    """Allowlist hygiene: entries must reference existing CEL rules and
    carry a reason."""
    rule_ids = {_rule_id(d) for d in CEL_RULE_DIRS}
    for rule, meta in KNOWN_BROKEN.items():
        assert rule in rule_ids, (
            "known_broken_cel_rules.yml lists %s which is not a CEL rule "
            "(fixed and renamed? remove the entry)" % rule)
        assert meta and meta.get("reason"), (
            "known_broken_cel_rules.yml entry %s needs a reason" % rule)
