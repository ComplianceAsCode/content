import pytest

import os
import re
import ssg.ansible


def no_whitespace_compare(left, right):
    return re.sub(r'\s', '', left) == re.sub(r'\s', '', right)


def test_add_minimum_version():
    good_snippet = """
 - hosts: all
   vars:
   tasks:
"""

    bad_snippet = """
 - hosts: all
   pre_tasks:
     - name: something_else
       assert:
         that: "2 > 3"
         msg: "two is less than three!"
   vars:
   tasks:
"""

    unknown_snippet = """
    I don't think this is YAML
"""

    processed_snippet = """
 - hosts: all
   pre_tasks:
     - name: Verify Ansible meets SCAP-Security-Guide version requirements.
       assert:
         that: "ansible_version.full is version_compare('2.3', '>=')"
         msg: >
           "You must update Ansible to at least version 2.3 to use this role."

   vars:
   tasks:
"""

    output = ssg.ansible.add_minimum_version(good_snippet)
    assert no_whitespace_compare(output, processed_snippet)

    with pytest.raises(ValueError):
        ssg.ansible.add_minimum_version(bad_snippet)

    assert ssg.ansible.add_minimum_version(unknown_snippet) == unknown_snippet

    assert ssg.ansible.add_minimum_version(processed_snippet) == processed_snippet
