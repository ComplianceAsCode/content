from __future__ import absolute_import

from .constants import *


def add_minimum_version(ansible_src):
    pre_task = (""" - hosts: all
   pre_tasks:
     - name: %s
       assert:
         that: "ansible_version.full is version_compare('%s', '>=')"
         msg: >
           "You must update Ansible to at least version %s to use this role."
          """ % (ansible_version_requirement_pre_task_name,
                 min_ansible_version, min_ansible_version))

    return ansible_src.replace(" - hosts: all", pre_task, 1)
