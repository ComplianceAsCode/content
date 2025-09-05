import os
import pytest

from .test_ansible_file_removed_and_added import check_playbook_file_removed_and_added


def test_file_removed_and_added():
    playbook_path = os.path.join(os.path.dirname(__file__),
                                 "ansible_file_removed_and_added",
                                 "file_removed_and_added.yml")
    assert not check_playbook_file_removed_and_added(playbook_path)


def test_file_removed_and_not_added():
    playbook_path = os.path.join(os.path.dirname(__file__),
                                 "ansible_file_removed_and_added",
                                 "file_removed_and_not_added.yml")
    assert check_playbook_file_removed_and_added(playbook_path)


def test_file_not_removed_and_added():
    playbook_path = os.path.join(os.path.dirname(__file__),
                                 "ansible_file_removed_and_added",
                                 "file_not_removed_and_added.yml")
    assert check_playbook_file_removed_and_added(playbook_path)


def test_file_block_removed_and_added():
    playbook_path = os.path.join(os.path.dirname(__file__),
                                 "ansible_file_removed_and_added",
                                 "file_block_removed_and_added.yml")
    assert not check_playbook_file_removed_and_added(playbook_path)


def test_file_block_removed_and_not_added():
    playbook_path = os.path.join(os.path.dirname(__file__),
                                 "ansible_file_removed_and_added",
                                 "file_block_removed_and_not_added.yml")
    assert check_playbook_file_removed_and_added(playbook_path)
