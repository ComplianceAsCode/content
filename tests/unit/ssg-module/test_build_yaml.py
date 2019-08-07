import os
import tempfile

import yaml
import pytest

import ssg.build_yaml


PROJECT_ROOT = os.path.join(os.path.dirname(__file__), "..", "..", "..", )


def test_serialize_rule():
    filename = PROJECT_ROOT + "/linux_os/guide/system/accounts/accounts-restrictions/password_storage/no_empty_passwords/rule.yml"
    rule_ds = ssg.build_yaml.Rule.from_yaml(filename)
    rule_as_dict = rule_ds.to_contents_dict()

    with tempfile.NamedTemporaryFile("w+", delete=True) as f:
        yaml.dump(rule_as_dict, f)
        rule_ds_reloaded = ssg.build_yaml.Rule.from_yaml(f.name)

    reloaded_dict = rule_ds_reloaded.to_contents_dict()

    # Those two should be really equal if there are no jinja macros in the rule def.
    assert rule_as_dict == reloaded_dict


def test_make_items_product_specific():
    rule = ssg.build_yaml.Rule("something")

    rule.identifiers = {
        "cce@rhel6": "27100-7",
        "cce@rhel7": "27445-6",
        "cce@rhel8": "80901-2",
    }
    rule.make_refs_and_identifiers_product_specific("rhel7")
    assert "cce@rhel7" not in rule.identifiers
    assert "cce@rhel8" not in rule.identifiers
    assert rule.identifiers["cce"] == "27445-6"

    rule.identifiers = {
        "cce": "27100-7",
        "cce@rhel7": "27445-6",
    }
    with pytest.raises(Exception) as exc:
        rule.make_refs_and_identifiers_product_specific("rhel7")
    assert "'cce'" in str(exc)
    assert "identifiers" in str(exc)

    rule.identifiers = {
        "cce@rhel7": "27445-6",
        "cce": "27445-6",
    }
    rule.make_refs_and_identifiers_product_specific("rhel7")
    assert "cce@rhel7" not in rule.identifiers
    assert rule.identifiers["cce"] == "27445-6"

    rule.references = {
        "stigid@rhel6": "RHEL-06-000237",
        "stigid@rhel7": "040370",
        "stigid": "tralala",
    }
    with pytest.raises(ValueError) as exc:
        rule.make_refs_and_identifiers_product_specific("rhel7")
    assert "stigid" in str(exc)

    rule.references = {
        "stigid@rhel6": "RHEL-06-000237",
        "stigid@rhel7": "040370",
    }
    rule.make_refs_and_identifiers_product_specific("rhel7")
    assert rule.references["stigid"] == "RHEL-07-040370"

    rule.references = {
        "stigid@rhel6": "RHEL-06-000237",
        "stigid@rhel7": "040370",
    }
    rule.make_refs_and_identifiers_product_specific("rhel6")
    assert rule.references["stigid"] == "RHEL-06-000237"
    assert "stigid@rhel6" not in rule.references
