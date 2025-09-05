import pytest

import os
import ssg.playbook_builder
import yaml
import shutil


DATADIR = os.path.join(
    os.path.dirname(__file__),
    "test_playbook_builder_data"
)

product_yaml = os.path.join(DATADIR, "product.yml")
input_dir = os.path.join(DATADIR, "fixes")
output_dir = os.path.join(DATADIR, "playbooks")
resolved_rules_dir = os.path.join(DATADIR, "rules")
resolved_profiles_dir = os.path.join(DATADIR, "profiles")
rule = "selinux_state"
profile = "ospp"

real_output_filepath = os.path.join(output_dir, profile, rule + ".yml")
expected_output_filepath = os.path.join(DATADIR, "selinux_state.yml")


def test_build_rule_playbook():
    playbook_builder = ssg.playbook_builder.PlaybookBuilder(
        product_yaml, input_dir, output_dir, resolved_rules_dir, resolved_profiles_dir
    )
    playbook_builder.build(profile, rule)

    assert os.path.exists(real_output_filepath)

    with open(real_output_filepath, "r") as real_output:
        real_output_yaml = yaml.load(real_output)
    with open(expected_output_filepath, "r") as expected_output:
        expected_output_yaml = yaml.load(expected_output)

    real_play = real_output_yaml.pop()
    expected_play = expected_output_yaml.pop()
    assert real_play["become"] == expected_play["become"]
    assert real_play["hosts"] == expected_play["hosts"]
    assert real_play["name"] == expected_play["name"]
    real_vars = real_play["vars"]
    expected_vars = expected_play["vars"]
    assert len(real_vars) == len(expected_vars)
    assert real_vars["var_selinux_state"] == expected_vars["var_selinux_state"]
    real_tags = real_play["tags"]
    expected_tags = expected_play["tags"]
    assert len(real_tags) == len(expected_tags)
    for tag in expected_tags:
        assert tag in real_tags
    for t1, t2 in zip(real_tags, expected_tags):
        assert t1 == t2
    real_tasks = real_play["tasks"]
    expected_tasks = expected_play["tasks"]
    assert len(real_tasks) == len(expected_tasks)
    real_task = real_tasks.pop()
    expected_task = expected_tasks.pop()
    assert real_task["name"] == expected_task["name"]
    assert len(real_task.keys()) == len(expected_task.keys())
    shutil.rmtree(output_dir)


