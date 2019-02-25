import os
import tempfile

import yaml

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
