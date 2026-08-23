"""
Common functions for processing Ansible in SSG
"""

from __future__ import absolute_import

import collections
import copy
import re

from .constants import ansible_version_requirement_pre_task_name
from .constants import min_ansible_version
from . import yaml


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
    return re.sub(r'\n{4,}', '\n\n\n', ansible_src, count=0, flags=re.MULTILINE)


def remove_trailing_whitespace(ansible_src):
    """
    Remove trailing whitespace from each line in the given Ansible source string.

    Args:
        ansible_src (str): The Ansible source code as a string.

    Returns:
        str: The Ansible source code with trailing whitespace removed from each line.
    """

    return re.sub(r'[ \t]+$', '', ansible_src, count=0, flags=re.MULTILINE)


package_facts_task = collections.OrderedDict([
    ('name', 'Gather the package facts'),
    ('ansible.builtin.package_facts', {'manager': 'auto'}),
    ('tags', ['always'])
])
service_facts_task = collections.OrderedDict([
    ('name', 'Gather the service facts'),
    ('ansible.builtin.service_facts', None),
    ('tags', ['always'])
])


def task_is(task, names):
    """
    Check if the task is one of the given names.

    Args:
        task (dict): The task to check.
        names (list): List of task names to check against.

    Returns:
        bool: True if the task contains any of the given names as keys, False otherwise.
    """
    for name in names:
        if name in task:
            return True
    return False


class AnsibleSnippetsProcessor:
    """
    Processes Ansible snippets to optimize package management tasks.

    This class processes a collection of Ansible snippets by:
    - Collecting package-related tasks for batch processing
    - Skipping redundant package_facts tasks
    - Handling block tasks recursively
    - Preserving other tasks as-is
    """

    def __init__(self, all_snippets):
        """
        Initialize the processor with a collection of snippets.

        Args:
            all_snippets (list): List of Ansible snippet strings to process.
        """
        self.all_snippets = all_snippets
        self.package_tasks = []
        self.service_tasks = []
        self.other_tasks = []

    def _process_task(self, task):
        """
        Process a single task, determining how to handle it.

        Args:
            task (dict): The task to process.

        Returns:
            dict or None: The processed task, or None if the task should be skipped.
        """

        if task_is(task, ["block"]):
            # Process block tasks recursively
            new_block = []
            for subtask in task["block"]:
                if self._process_task(subtask) is not None:
                    new_block.append(subtask)
            task["block"] = new_block
            if "special_service_block" in task.get("tags", []):
                # Collect service tasks to be processed later
                self.service_tasks.append(task)
                return None
            return task if new_block else None
        if task_is(task, ["ansible.builtin.package_facts", "package_facts"]):
            # Skip package_facts tasks because they will be replaced by
            # a single package_facts task that will be added later
            return None
        if task_is(task, ["ansible.builtin.service_facts", "service_facts"]):
            # Skip service_facts tasks because they will be replaced by
            # a single service_facts task that will be added later
            return None
        if task_is(task, ["ansible.builtin.package", "package"]):
            # Collect package tasks to be processed later
            self.package_tasks.append(task)
            return None
        return task

    def _process_snippet(self, snippet):
        """
        Process a single snippet, extracting tasks from it.

        Args:
            snippet (str): The YAML snippet string to process.
        """
        tasks = yaml.ordered_load(snippet)
        for task in tasks:
            if self._process_task(task) is not None:
                self.other_tasks.append(task)

    def process_snippets(self):
        """
        Process all snippets provided during initialization.
        """
        for snippet in self.all_snippets:
            self._process_snippet(snippet)

    def get_ansible_tasks(self):
        """
        Get the final list of processed Ansible tasks.

        Package facts tasks are added at the beginning and end of package tasks,
        then combined with other tasks.

        Returns:
            list: Combined list of all processed tasks.
        """
        return [package_facts_task, *self.package_tasks, copy.deepcopy(package_facts_task), *self.service_tasks, service_facts_task, *self.other_tasks]
