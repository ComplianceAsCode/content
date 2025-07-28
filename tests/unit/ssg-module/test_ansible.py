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


def test_task_is():
    # Test with task containing one of the names
    task_with_package = {"ansible.builtin.package": {"name": "vim"}}
    assert ssg.ansible.task_is(task_with_package, ["package", "ansible.builtin.package"])

    # Test with task containing different name
    assert ssg.ansible.task_is(task_with_package, ["ansible.builtin.package"])

    # Test with task not containing any of the names
    task_with_copy = {"copy": {"src": "file", "dest": "/tmp"}}
    assert not ssg.ansible.task_is(task_with_copy, ["package", "ansible.builtin.package"])

    # Test with empty names list
    assert not ssg.ansible.task_is(task_with_package, [])

    # Test with empty task
    assert not ssg.ansible.task_is({}, ["package"])


class TestAnsibleSnippetsProcessor:

    def test_initialization(self):
        """Test processor initialization."""
        snippets = ["snippet1", "snippet2"]
        processor = ssg.ansible.AnsibleSnippetsProcessor(snippets)

        assert processor.all_snippets == snippets
        assert processor.package_tasks == []
        assert processor.other_tasks == []

    def test_process_task_package(self):
        """Test processing of package tasks."""
        processor = ssg.ansible.AnsibleSnippetsProcessor([])

        package_task = {"ansible.builtin.package": {"name": "vim"}}
        result = processor._process_task(package_task)

        assert result is None  # Package tasks should be skipped from immediate processing
        assert package_task in processor.package_tasks

    def test_process_task_package_facts(self):
        """Test processing of package_facts tasks."""
        processor = ssg.ansible.AnsibleSnippetsProcessor([])

        package_facts_task = {"ansible.builtin.package_facts": {"manager": "auto"}}
        result = processor._process_task(package_facts_task)

        assert result is None  # package_facts tasks should be skipped
        assert len(processor.package_tasks) == 0  # Should not be added to package_tasks

    def test_process_task_package_facts_short_name(self):
        """Test processing of package_facts tasks with short name."""
        processor = ssg.ansible.AnsibleSnippetsProcessor([])

        package_facts_task = {"package_facts": {"manager": "auto"}}
        result = processor._process_task(package_facts_task)

        assert result is None  # package_facts tasks should be skipped

    def test_process_task_service_facts(self):
        """Test processing of service_facts tasks."""
        processor = ssg.ansible.AnsibleSnippetsProcessor([])

        service_facts_task = {"ansible.builtin.service_facts": None}
        result = processor._process_task(service_facts_task)

        assert result is None  # service_facts tasks should be skipped
        assert len(processor.other_tasks) == 0  # Should not be added to other_tasks

    def test_process_task_other(self):
        """Test processing of other tasks."""
        processor = ssg.ansible.AnsibleSnippetsProcessor([])

        copy_task = {"copy": {"src": "file", "dest": "/tmp"}}
        result = processor._process_task(copy_task)

        assert result == copy_task  # Other tasks should be returned as-is
        assert len(processor.package_tasks) == 0
        assert len(processor.other_tasks) == 0  # _process_task doesn't add to other_tasks

    def test_process_task_block_empty(self):
        """Test processing of empty block tasks."""
        processor = ssg.ansible.AnsibleSnippetsProcessor([])

        block_task = {"block": []}
        result = processor._process_task(block_task)

        assert result is None  # Empty blocks should be filtered out

    def test_process_task_block_with_content(self):
        """Test processing of block tasks with content."""
        processor = ssg.ansible.AnsibleSnippetsProcessor([])

        block_task = {
            "block": [
                {"copy": {"src": "file", "dest": "/tmp"}},
                {"ansible.builtin.package": {"name": "vim"}},
                {"ansible.builtin.package_facts": {"manager": "auto"}}
            ]
        }
        result = processor._process_task(block_task)

        # Should return block with only the copy task (package tasks are collected, package_facts skipped)
        assert result is not None
        assert "block" in result
        assert len(result["block"]) == 1
        assert result["block"][0] == {"copy": {"src": "file", "dest": "/tmp"}}
        assert len(processor.package_tasks) == 1

    def test_process_task_block_all_filtered(self):
        """Test processing of block tasks where all subtasks are filtered."""
        processor = ssg.ansible.AnsibleSnippetsProcessor([])

        block_task = {
            "block": [
                {"ansible.builtin.package": {"name": "vim"}},
                {"ansible.builtin.package_facts": {"manager": "auto"}}
            ]
        }
        result = processor._process_task(block_task)

        assert result is None  # Block should be None if all subtasks are filtered
        assert len(processor.package_tasks) == 1

    def test_process_snippet(self):
        """Test processing of a complete snippet."""
        processor = ssg.ansible.AnsibleSnippetsProcessor([])

        snippet = """
        - name: Install vim
          ansible.builtin.package:
            name: vim
        - name: Gather facts
          ansible.builtin.package_facts:
            manager: auto
        - name: Copy file
          copy:
            src: file
            dest: /tmp
        """

        processor._process_snippet(snippet)

        assert len(processor.package_tasks) == 1
        assert len(processor.other_tasks) == 1
        assert processor.other_tasks[0]["copy"]["src"] == "file"

    def test_process_snippets(self):
        """Test processing multiple snippets."""
        snippet1 = """
        - name: Install vim
          ansible.builtin.package:
            name: vim
        """

        snippet2 = """
        - name: Copy file
          copy:
            src: file
            dest: /tmp
        """

        processor = ssg.ansible.AnsibleSnippetsProcessor([snippet1, snippet2])
        processor.process_snippets()

        assert len(processor.package_tasks) == 1
        assert len(processor.other_tasks) == 1

    def test_get_ansible_tasks(self):
        """Test getting the final ansible tasks."""
        snippet = """
        - name: Install vim
          ansible.builtin.package:
            name: vim
        - name: Copy file
          copy:
            src: file
            dest: /tmp
        """

        processor = ssg.ansible.AnsibleSnippetsProcessor([snippet])
        processor.process_snippets()

        tasks = processor.get_ansible_tasks()

        # Should have: package_facts_task + package_task + package_facts_task + service_facts_task + other_task
        assert len(tasks) == 5
        assert tasks[0] == ssg.ansible.package_facts_task  # First package facts task
        assert "ansible.builtin.package" in tasks[1]  # Package task
        assert tasks[2] == ssg.ansible.package_facts_task  # Second package facts task
        assert "ansible.builtin.service_facts" in tasks[3]  # Service facts task
        assert "copy" in tasks[4]  # Other task

    def test_get_ansible_tasks_no_package_tasks(self):
        """Test getting ansible tasks when there are no package tasks."""
        snippet = """
        - name: Copy file
          copy:
            src: file
            dest: /tmp
        """

        processor = ssg.ansible.AnsibleSnippetsProcessor([snippet])
        processor.process_snippets()

        tasks = processor.get_ansible_tasks()

        # Should have: package_facts_task + package_facts_task + service_facts_task + other_task
        assert len(tasks) == 4
        assert tasks[0] == ssg.ansible.package_facts_task
        assert tasks[1] == ssg.ansible.package_facts_task
        assert tasks[2] == ssg.ansible.service_facts_task
        assert "copy" in tasks[3]  # Other task

    def test_empty_snippets(self):
        """Test processing empty snippets list."""
        processor = ssg.ansible.AnsibleSnippetsProcessor([])
        processor.process_snippets()

        tasks = processor.get_ansible_tasks()

        # Should have only the two package facts tasks and service facts task
        assert len(tasks) == 3
        assert tasks[0] == ssg.ansible.package_facts_task
        assert tasks[1] == ssg.ansible.package_facts_task
        assert tasks[2] == ssg.ansible.service_facts_task

    def test_malformed_snippet(self):
        """Test handling of malformed YAML snippets."""
        processor = ssg.ansible.AnsibleSnippetsProcessor(["invalid: yaml: content:"])

        # This should raise SystemExit when trying to parse invalid YAML
        with pytest.raises(SystemExit):
            processor.process_snippets()

    def test_process_task_special_service_block(self):
      """Test processing of special service block tasks."""
      processor = ssg.ansible.AnsibleSnippetsProcessor([])

      service_task = {
        "name": "Enable service sshd",
        "block": [{"name":"Gather package facts", "ansible.builtin.package_facts": {"manager": "auto"}}, {"name": "Enable service sshd", "ansible.builtin.systemd": {"name": "sshd"}}],
        "tags": ["special_service_block"]
      }
      result = processor._process_task(service_task)

      assert result is None  # Service tasks should be skipped
      assert len(processor.service_tasks) == 1
      assert processor.service_tasks[0] == service_task
      assert "ansible.builtin.package_facts" not in processor.service_tasks[0]["block"][0]
