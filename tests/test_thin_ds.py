#!/usr/bin/env python3

# Usage (Execute in root project directory): python3 -m pytest -n auto tests/test_thin_ds.py

import pytest
import subprocess

from lxml import etree

from pathlib import Path


THIN_DS_PATHS = []
for path in Path("./build/thin_ds").glob("*.xml"):
    THIN_DS_PATHS.append(path)


@pytest.mark.parametrize("path", THIN_DS_PATHS)
def test_thin_ds(path):
    root = etree.parse(path)

    rules = root.findall(".//{http://checklists.nist.gov/xccdf/1.2}Rule")
    assert len(rules) == 1

    rule_id = rules[0].get("id", "NoID").rsplit(".content_rule_", 1)[-1]
    assert rule_id in str(path)

    profiles = root.findall(".//{http://checklists.nist.gov/xccdf/1.2}Profile")
    assert len(profiles) == 1

    profile_id = profiles[0].get("id", "NoID").rsplit(".content_profile_", 1)[-1]
    assert profile_id in str(path)


@pytest.mark.parametrize("path", THIN_DS_PATHS)
def test_validate_thin_ds(path):
    command = subprocess.run(["oscap", "ds", "sds-validate", path], capture_output=True)
    assert command.returncode == 0
