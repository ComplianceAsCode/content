import os
import re
import textwrap
from collections import OrderedDict

import pytest

import ssg.ansible
from ssg.constants import min_ansible_version


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
