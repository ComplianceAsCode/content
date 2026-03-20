import os
import textwrap

import pytest
import yaml

from utils.cel_bundler import bundle_from_dirs, bundle_to_file, bundle_to_yaml


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _write(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as fh:
        fh.write(textwrap.dedent(content))


def _make_rule(tmp_path, filename, name="my-rule", expression='"true"',
               inputs=None):
    """Write a minimal valid rule YAML and return its path."""
    if inputs is None:
        inputs = (
            "inputs:\n"
            "  - name: pods\n"
            "    kubernetesInputSpec:\n"
            "      apiVersion: v1\n"
            "      resource: pods\n"
        )
    content = (
        f"name: {name}\n"
        f"id: {name.replace('-', '_')}\n"
        f"title: Title for {name}\n"
        f"severity: medium\n"
        f"checkType: Platform\n"
        f"expression: {expression}\n"
        f"{inputs}"
    )
    path = os.path.join(tmp_path, "rules", filename)
    _write(path, content)
    return path


def _make_profile(tmp_path, filename, name="my-profile", rules=None):
    """Write a minimal valid profile YAML and return its path."""
    if rules is None:
        rules = ["my-rule"]
    rules_yaml = "\n".join(f"  - {r}" for r in rules)
    content = (
        f"name: {name}\n"
        f"id: {name.replace('-', '_')}\n"
        f"title: Title for {name}\n"
        f"productType: Platform\n"
        f"rules:\n{rules_yaml}\n"
    )
    path = os.path.join(tmp_path, "profiles", filename)
    _write(path, content)
    return path


def _setup_dirs(tmp_path):
    rules_dir = os.path.join(tmp_path, "rules")
    profiles_dir = os.path.join(tmp_path, "profiles")
    os.makedirs(rules_dir, exist_ok=True)
    os.makedirs(profiles_dir, exist_ok=True)
    return rules_dir, profiles_dir


# ---------------------------------------------------------------------------
# Happy-path tests
# ---------------------------------------------------------------------------

class TestBundleFromDirs:
    def test_single_rule_single_profile(self, tmp_path):
        rules_dir, profiles_dir = _setup_dirs(tmp_path)
        _make_rule(tmp_path, "r.yaml")
        _make_profile(tmp_path, "p.yaml")

        bundle = bundle_from_dirs(rules_dir, profiles_dir)
        assert len(bundle["rules"]) == 1
        assert len(bundle["profiles"]) == 1
        assert bundle["rules"][0]["name"] == "my-rule"
        assert bundle["profiles"][0]["name"] == "my-profile"

    def test_rules_sorted_by_name(self, tmp_path):
        rules_dir, profiles_dir = _setup_dirs(tmp_path)
        _make_rule(tmp_path, "z.yaml", name="z-rule")
        _make_rule(tmp_path, "a.yaml", name="a-rule")
        _make_profile(tmp_path, "p.yaml", rules=["a-rule", "z-rule"])

        bundle = bundle_from_dirs(rules_dir, profiles_dir)
        assert [r["name"] for r in bundle["rules"]] == ["a-rule", "z-rule"]

    def test_profiles_sorted_by_name(self, tmp_path):
        rules_dir, profiles_dir = _setup_dirs(tmp_path)
        _make_rule(tmp_path, "r.yaml")
        _make_profile(tmp_path, "z.yaml", name="z-profile")
        _make_profile(tmp_path, "a.yaml", name="a-profile")

        bundle = bundle_from_dirs(rules_dir, profiles_dir)
        assert [p["name"] for p in bundle["profiles"]] == [
            "a-profile", "z-profile"
        ]

    def test_non_yaml_files_ignored(self, tmp_path):
        rules_dir, profiles_dir = _setup_dirs(tmp_path)
        _make_rule(tmp_path, "r.yaml")
        _write(os.path.join(rules_dir, "README.md"), "# ignore me")
        _write(os.path.join(profiles_dir, ".gitkeep"), "")
        _make_profile(tmp_path, "p.yaml")

        bundle = bundle_from_dirs(rules_dir, profiles_dir)
        assert len(bundle["rules"]) == 1

    def test_yml_extension_accepted(self, tmp_path):
        rules_dir, profiles_dir = _setup_dirs(tmp_path)
        _make_rule(tmp_path, "r.yml")
        _make_profile(tmp_path, "p.yml")

        bundle = bundle_from_dirs(rules_dir, profiles_dir)
        assert len(bundle["rules"]) == 1

    def test_rule_fields_preserved(self, tmp_path):
        rules_dir, profiles_dir = _setup_dirs(tmp_path)
        rule_yaml = textwrap.dedent("""\
            name: check-pods
            id: check_pods
            title: Check pods
            description: Ensure pods exist.
            rationale: Pods are important.
            severity: high
            checkType: Platform
            expression: "pods.items.size() > 0"
            inputs:
              - name: pods
                kubernetesInputSpec:
                  apiVersion: v1
                  resource: pods
                  resourceNamespace: default
            failureReason: No pods found.
            instructions: Run oc get pods.
            controls:
              NIST-800-53:
                - AC-6
                - CM-7
              CIS-OCP:
                - "5.7.4"
        """)
        _write(os.path.join(rules_dir, "r.yaml"), rule_yaml)
        _make_profile(tmp_path, "p.yaml", name="p", rules=["check-pods"])

        bundle = bundle_from_dirs(rules_dir, profiles_dir)
        rule = bundle["rules"][0]
        assert rule["id"] == "check_pods"
        assert rule["severity"] == "high"
        assert rule["description"] == "Ensure pods exist."
        assert rule["rationale"] == "Pods are important."
        assert rule["failureReason"] == "No pods found."
        assert rule["instructions"] == "Run oc get pods."
        assert rule["inputs"][0]["kubernetesInputSpec"]["resourceNamespace"] == "default"
        assert rule["controls"]["NIST-800-53"] == ["AC-6", "CM-7"]
        assert rule["controls"]["CIS-OCP"] == ["5.7.4"]

    def test_profile_version_preserved(self, tmp_path):
        rules_dir, profiles_dir = _setup_dirs(tmp_path)
        _make_rule(tmp_path, "r.yaml")
        profile_yaml = textwrap.dedent("""\
            name: my-profile
            id: my_profile
            title: My Profile
            productType: Platform
            version: "1.2.3"
            rules:
              - my-rule
            values:
              - var-timeout
        """)
        _write(os.path.join(profiles_dir, "p.yaml"), profile_yaml)

        bundle = bundle_from_dirs(rules_dir, profiles_dir)
        profile = bundle["profiles"][0]
        assert profile["version"] == "1.2.3"
        assert profile["values"] == ["var-timeout"]


# ---------------------------------------------------------------------------
# Validation error tests
# ---------------------------------------------------------------------------

class TestBundleValidation:
    def test_rule_missing_name(self, tmp_path):
        rules_dir, profiles_dir = _setup_dirs(tmp_path)
        _write(
            os.path.join(rules_dir, "r.yaml"),
            'id: x\nseverity: medium\ncheckType: Platform\n'
            'expression: "true"\ninputs:\n  - name: x\n'
            '    kubernetesInputSpec:\n      apiVersion: v1\n'
            '      resource: pods\n',
        )
        with pytest.raises(ValueError, match="has no name"):
            bundle_from_dirs(rules_dir, profiles_dir)

    def test_rule_missing_expression(self, tmp_path):
        rules_dir, profiles_dir = _setup_dirs(tmp_path)
        _write(
            os.path.join(rules_dir, "r.yaml"),
            'name: x\nid: x\nseverity: medium\ncheckType: Platform\n'
            'inputs:\n  - name: x\n    kubernetesInputSpec:\n'
            '      apiVersion: v1\n      resource: pods\n',
        )
        with pytest.raises(ValueError, match="has no expression"):
            bundle_from_dirs(rules_dir, profiles_dir)

    def test_rule_missing_inputs(self, tmp_path):
        rules_dir, profiles_dir = _setup_dirs(tmp_path)
        _write(
            os.path.join(rules_dir, "r.yaml"),
            'name: x\nid: x\nseverity: medium\ncheckType: Platform\n'
            'expression: "true"\n',
        )
        with pytest.raises(ValueError, match="has no inputs"):
            bundle_from_dirs(rules_dir, profiles_dir)

    def test_profile_missing_name(self, tmp_path):
        rules_dir, profiles_dir = _setup_dirs(tmp_path)
        _make_rule(tmp_path, "r.yaml")
        _write(
            os.path.join(profiles_dir, "p.yaml"),
            "id: x\ntitle: X\nrules:\n  - my-rule\n",
        )
        with pytest.raises(ValueError, match="has no name"):
            bundle_from_dirs(rules_dir, profiles_dir)

    def test_profile_missing_rules(self, tmp_path):
        rules_dir, profiles_dir = _setup_dirs(tmp_path)
        _make_rule(tmp_path, "r.yaml")
        _write(
            os.path.join(profiles_dir, "p.yaml"),
            "name: p\nid: p\ntitle: P\n",
        )
        with pytest.raises(ValueError, match="has no rules"):
            bundle_from_dirs(rules_dir, profiles_dir)

    def test_duplicate_rule_name(self, tmp_path):
        rules_dir, profiles_dir = _setup_dirs(tmp_path)
        _make_rule(tmp_path, "a.yaml", name="dup")
        _make_rule(tmp_path, "b.yaml", name="dup")
        _make_profile(tmp_path, "p.yaml", rules=["dup"])

        with pytest.raises(ValueError, match="duplicate rule name"):
            bundle_from_dirs(rules_dir, profiles_dir)

    def test_unknown_rule_reference(self, tmp_path):
        rules_dir, profiles_dir = _setup_dirs(tmp_path)
        _make_rule(tmp_path, "r.yaml", name="real-rule")
        _make_profile(tmp_path, "p.yaml", name="p",
                       rules=["real-rule", "ghost-rule"])

        with pytest.raises(ValueError, match="unknown rule"):
            bundle_from_dirs(rules_dir, profiles_dir)


# ---------------------------------------------------------------------------
# Serialization tests
# ---------------------------------------------------------------------------

class TestBundleToYAML:
    def test_roundtrip(self, tmp_path):
        rules_dir, profiles_dir = _setup_dirs(tmp_path)
        _make_rule(tmp_path, "r.yaml")
        _make_profile(tmp_path, "p.yaml")

        bundle = bundle_from_dirs(rules_dir, profiles_dir)
        yaml_str = bundle_to_yaml(bundle)
        loaded = yaml.safe_load(yaml_str)

        assert len(loaded["rules"]) == 1
        assert len(loaded["profiles"]) == 1
        assert loaded["rules"][0]["name"] == "my-rule"
        assert loaded["profiles"][0]["name"] == "my-profile"

    def test_keys_sorted_alphabetically(self, tmp_path):
        rules_dir, profiles_dir = _setup_dirs(tmp_path)
        _make_rule(tmp_path, "r.yaml")
        _make_profile(tmp_path, "p.yaml")

        bundle = bundle_from_dirs(rules_dir, profiles_dir)
        yaml_str = bundle_to_yaml(bundle)

        assert yaml_str.index("profiles:") < yaml_str.index("rules:")
        rule_block = yaml_str[yaml_str.index("rules:"):]
        assert rule_block.index("checkType") < rule_block.index("name")


class TestBundleToFile:
    def test_writes_valid_yaml(self, tmp_path):
        rules_dir, profiles_dir = _setup_dirs(tmp_path)
        _make_rule(tmp_path, "r.yaml")
        _make_profile(tmp_path, "p.yaml")
        output = os.path.join(tmp_path, "bundle.yaml")

        bundle_to_file(rules_dir, profiles_dir, output)

        with open(output) as fh:
            loaded = yaml.safe_load(fh)
        assert len(loaded["rules"]) == 1
        assert len(loaded["profiles"]) == 1

    def test_error_propagates(self, tmp_path):
        rules_dir, profiles_dir = _setup_dirs(tmp_path)
        _write(os.path.join(rules_dir, "bad.yaml"), "id: no-name\n")
        output = os.path.join(tmp_path, "bundle.yaml")

        with pytest.raises(ValueError, match="has no name"):
            bundle_to_file(rules_dir, profiles_dir, output)
        assert not os.path.exists(output)
