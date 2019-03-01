import os
import re
import textwrap
from collections import OrderedDict

import pytest

import ssg.ansible
from ssg.constants import min_ansible_version
from ssg.yaml import ordered_load


DATADIR = os.path.join(os.path.dirname(__file__), "data")


def strings_equal_except_whitespaces(left, right):
    return re.sub(r'\s', '', left) == re.sub(r'\s', '', right)


def test_add_minimum_version():
    good_snippet = """
    # a comment
     - hosts: all
       vars:
       tasks:
    """
    good_snippet = textwrap.dedent(good_snippet)

    bad_snippet = """
    # a comment
     - hosts: all
       pre_tasks:
         - name: something_else
           assert:
             that: "2 > 3"
             msg: "two is less than three!"
       vars:
       tasks:
    """
    bad_snippet = textwrap.dedent(bad_snippet)

    unknown_snippet = """
    I don't think this is YAML
    """

    processed_snippet = """
    # a comment
     - hosts: all
       pre_tasks:
         - name: Verify Ansible meets SCAP-Security-Guide version requirements.
           assert:
             that: "ansible_version.full is version_compare('{min_version}', '>=')"
             msg: >
               "You must update Ansible to at least version {min_version} to use this role."

       vars:
       tasks:
    """.format(min_version=min_ansible_version)
    processed_snippet = textwrap.dedent(processed_snippet)

    output = ssg.ansible.add_minimum_version(good_snippet)
    assert strings_equal_except_whitespaces(output, processed_snippet)

    with pytest.raises(ValueError):
        ssg.ansible.add_minimum_version(bad_snippet)

    assert ssg.ansible.add_minimum_version(unknown_snippet) == unknown_snippet

    assert ssg.ansible.add_minimum_version(processed_snippet) == processed_snippet


def test_when_update():
    assert ssg.ansible.update_yaml_list_or_string(
        "",
        "",
    ) == ""

    assert ssg.ansible.update_yaml_list_or_string(
        "something",
        "",
    ) == "something"

    assert ssg.ansible.update_yaml_list_or_string(
        ["something"],
        "",
    ) == "something"

    assert ssg.ansible.update_yaml_list_or_string(
        "",
        "else",
    ) == "else"

    assert ssg.ansible.update_yaml_list_or_string(
        "something",
        "else",
    ) == ["something", "else"]

    assert ssg.ansible.update_yaml_list_or_string(
        "",
        ["something", "else"],
    ) == ["something", "else"]

    assert ssg.ansible.update_yaml_list_or_string(
        ["something", "else"],
        "",
    ) == ["something", "else"]

    assert ssg.ansible.update_yaml_list_or_string(
        "something",
        ["entirely", "else"],
    ) == ["something", "entirely", "else"]

    assert ssg.ansible.update_yaml_list_or_string(
        ["something", "entirely"],
        ["entirely", "else"],
    ) == ["something", "entirely", "entirely", "else"]


def test_ansible_class():
    remediation = ssg.ansible.AnsibleRemediation.from_snippet_and_rule(
        os.path.join(DATADIR, "ansible.yml"), os.path.join(DATADIR, "file_owner_grub2_cfg.yml")
    )

    assert remediation.config["reboot"] == 'false'
    assert remediation.config["strategy"] == 'configure'
    assert remediation.config["complexity"] == 'low'
    assert remediation.config["disruption"] == 'low'


def test_ansible_conformance():
    remediation = ssg.ansible.AnsibleRemediation.from_snippet_and_rule(
        os.path.join(DATADIR, "ansible.yml"), os.path.join(DATADIR, "file_owner_grub2_cfg.yml")
    )
    ref_remediation_dict = ordered_load(open(os.path.join(DATADIR, "ansible-resolved.yml")))

    remediation.update("rhel7")

    # The comparison has to be done this way due to possible order variations,
    # which don't matter, but they make tests to fail.
    assert set(remediation.parsed[0]["tags"]) == set(ref_remediation_dict[0]["tags"])
    assert set(remediation.parsed[1]["tags"]) == set(ref_remediation_dict[1]["tags"])
    assert set(remediation.parsed[0]["when"]) == set(ref_remediation_dict[0]["when"])
    assert set(remediation.parsed[1]["when"]) == set(ref_remediation_dict[1]["when"])
    assert set(remediation.parsed[0]["name"]) == set(ref_remediation_dict[0]["name"])
