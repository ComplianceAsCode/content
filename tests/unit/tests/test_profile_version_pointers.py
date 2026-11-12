"""
Unit tests for tests/test_profile_version_pointers.py.

The module under test is loaded with importlib rather than a plain
`import test_profile_version_pointers` because its filename is the same as
this file's: a path-based import would collide with pytest's own module
bookkeeping for whichever of the two is collected first.
"""

import importlib.util
import os


def _load_module_under_test():
    path = os.path.join(
        os.path.dirname(__file__), "..", "..", "test_profile_version_pointers.py")
    spec = importlib.util.spec_from_file_location(
        "profile_version_pointers_under_test", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


tpvp = _load_module_under_test()


def _write_profile(profiles_dir, name, extends=None, version=None,
                   selections=None, documentation_complete=True):
    lines = [
        "documentation_complete: {0}".format(
            "true" if documentation_complete else "false"),
        "title: 'Test profile {0}'".format(name),
        "description: 'Test profile {0}'".format(name),
    ]
    if extends:
        lines.append("extends: {0}".format(extends))
    if version:
        lines.append("metadata:")
        lines.append("    version: {0}".format(version))
    if selections:
        lines.append("selections:")
        for selection in selections:
            lines.append("    - {0}".format(selection))
    else:
        lines.append("selections: []")

    path = os.path.join(profiles_dir, name + ".profile")
    with open(path, "w") as f:
        f.write("\n".join(lines) + "\n")
    return path


def test_is_version_suffix_matches_known_forms():
    for suffix in ("2-0", "1-9", "2022", "rev-4", "v2r6", "V2R6"):
        assert tpvp.is_version_suffix(suffix)


def test_is_version_suffix_rejects_sibling_profile_names():
    for suffix in ("node", "vm-extension", "latest", ""):
        assert not tpvp.is_version_suffix(suffix)


def test_version_sort_key_ranks_numerically_not_lexically():
    # Lexical comparison would rank "V2R10" below "V2R6".
    assert tpvp.version_sort_key("V2R6") < tpvp.version_sort_key("V2R10")
    assert tpvp.version_sort_key("1.9.0") < tpvp.version_sort_key("2.0.0")


def test_version_sort_key_handles_missing_version():
    assert tpvp.version_sort_key(None) == ()


def test_find_versioned_variants_excludes_sibling_profiles():
    profiles = {
        "ocp4-cis": {},
        "ocp4-cis-2-0": {},
        "ocp4-cis-1-9": {},
        "ocp4-cis-node": {},
        "ocp4-cis-node-2-0": {},
        "ocp4-cis-vm-extension": {},
    }
    variants = tpvp.find_versioned_variants(profiles)
    assert sorted(variants["ocp4-cis"]) == ["ocp4-cis-1-9", "ocp4-cis-2-0"]
    assert variants["ocp4-cis-node"] == ["ocp4-cis-node-2-0"]
    assert "ocp4-cis-vm-extension" not in variants


def test_check_product_passes_when_pointer_is_current(tmp_path):
    product_dir = str(tmp_path / "ocp4")
    profiles_dir = os.path.join(product_dir, "profiles")
    os.makedirs(profiles_dir)
    _write_profile(profiles_dir, "cis-1-9", version="1.9.0")
    _write_profile(profiles_dir, "cis-2-0", version="2.0.0")
    _write_profile(profiles_dir, "cis", extends="cis-2-0", version="2.0.0")

    assert tpvp.check_product("ocp4", product_dir) == []


def test_check_product_flags_stale_pointer(tmp_path):
    product_dir = str(tmp_path / "ocp4")
    profiles_dir = os.path.join(product_dir, "profiles")
    os.makedirs(profiles_dir)
    _write_profile(profiles_dir, "cis-1-9", version="1.9.0")
    _write_profile(profiles_dir, "cis-2-0", version="2.0.0")
    _write_profile(profiles_dir, "cis", extends="cis-1-9", version="1.9.0")

    failures = tpvp.check_product("ocp4", product_dir)
    assert len(failures) == 1
    assert "cis-1-9" in failures[0] and "cis-2-0" in failures[0]


def test_check_product_flags_version_mismatch(tmp_path):
    product_dir = str(tmp_path / "ocp4")
    profiles_dir = os.path.join(product_dir, "profiles")
    os.makedirs(profiles_dir)
    _write_profile(profiles_dir, "cis-2-0", version="2.0.0")
    _write_profile(profiles_dir, "cis", extends="cis-2-0", version="1.9.0")

    failures = tpvp.check_product("ocp4", product_dir)
    assert len(failures) == 1
    assert "declares version 1.9.0" in failures[0]


def test_check_product_ignores_profile_with_its_own_content(tmp_path):
    # ocp4-cis-node has a versioned relative but does not extend it, so it is
    # out of scope: this check is only about the extends-pointer indirection.
    product_dir = str(tmp_path / "ocp4")
    profiles_dir = os.path.join(product_dir, "profiles")
    os.makedirs(profiles_dir)
    _write_profile(profiles_dir, "cis-node-2-0", version="2.0.0")
    _write_profile(profiles_dir, "cis-node", selections=["some_rule"], version="2.0.0")

    assert tpvp.check_product("ocp4", product_dir) == []


def test_check_product_skips_documentation_incomplete_profiles(tmp_path):
    product_dir = str(tmp_path / "ocp4")
    profiles_dir = os.path.join(product_dir, "profiles")
    os.makedirs(profiles_dir)
    _write_profile(profiles_dir, "cis-1-9", version="1.9.0")
    _write_profile(
        profiles_dir, "cis-2-0", version="2.0.0", documentation_complete=False)
    _write_profile(profiles_dir, "cis", extends="cis-1-9", version="1.9.0")

    # cis-2-0 is not yet shipped, so cis-1-9 is the newest variant that counts.
    assert tpvp.check_product("ocp4", product_dir) == []
