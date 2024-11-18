"""
Common functions for processing Ansible in SSG
"""

from __future__ import absolute_import
from __future__ import print_function

import re

from .constants import ansible_version_requirement_pre_task_name
from .constants import min_ansible_version


def add_minimum_version(ansible_src):
    """
    Adds a minimum Ansible version requirement to an Ansible script.

    This function inserts a pre_task into the provided Ansible script to assert
    that the Ansible version is greater than or equal to a specified minimum version.
    If the script already contains a pre_task or the version check, it will return
    the original script. If a pre_task exists but does not contain the version check,
    it raises a ValueError.

    Args:
        ansible_src (str): The source code of the Ansible script.

    Returns:
        str: The modified Ansible script with the minimum version requirement added.

    Raises:
        ValueError: If a pre_task already exists in the Ansible script but does not
                    contain the version check.
    """
    pre_task = (""" - hosts: all
   pre_tasks:
     - name: %s
       assert:
         that: "ansible_version.full is version_compare('%s', '>=')"
         msg: >
           "You must update Ansible to at least version %s to use this role."
          """ % (ansible_version_requirement_pre_task_name,
                 min_ansible_version, min_ansible_version))

    if ' - hosts: all' not in ansible_src:
        return ansible_src

    if 'pre_task' in ansible_src:
        if 'ansible_version.full is version_compare' in ansible_src:
            return ansible_src

        raise ValueError(
            "A pre_task already exists in ansible_src; failing to process: %s" %
            ansible_src)

    return ansible_src.replace(" - hosts: all", pre_task, 1)


def remove_too_many_blank_lines(ansible_src):
    """
    Condenses three or more consecutive empty lines into two empty lines.

    Args:
        ansible_src (str): The source string from an Ansible file.

    Returns:
        str: The modified string with excessive blank lines reduced.
    """
    return re.sub(r'\n{4,}', '\n\n\n', ansible_src, 0, flags=re.M)


def remove_trailing_whitespace(ansible_src):
    """
    Remove trailing whitespace from each line in the given Ansible source string.

    Args:
        ansible_src (str): The Ansible source code as a string.

    Returns:
        str: The Ansible source code with trailing whitespace removed from each line.
    """

    return re.sub(r'[ \t]+$', '', ansible_src, 0, flags=re.M)
