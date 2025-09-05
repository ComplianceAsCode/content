#!/usr/bin/python3

import yaml
import argparse
import subprocess
from pathlib import Path


def parse_args():
    parser = argparse.ArgumentParser(
            description="Check for changes in 'shell' module usage in two datastreams"
    )
    parser.add_argument('old', metavar='OLD_DS_PATH', help="Path to old datastream")
    parser.add_argument('new', metavar='NEW_DS_PATH', help="Path to new datastream")
    return parser.parse_args()


def get_shell_tasks(tasks):
    """
    Find all shell/command module tasks.
    Module can be as FQCN or just short name.
    Both forms, free form and 'cmd:' parameter, are supported.
    """
    shell_tasks = []
    for task in tasks:
        for task_name in ['shell', 'ansible.builtin.shell', 'command', 'ansible.builtin.command']:
            if task_name in task:
                if type(task[task_name]) is dict and 'cmd' in task[task_name]:
                    shell_tasks.append(task[task_name]['cmd'])
                else:
                    shell_tasks.append(task[task_name])
        # Search also blocks
        if 'block' in task:
            tasks = get_shell_tasks(task['block'])
            if tasks:
                shell_tasks.extend(tasks)
    return shell_tasks


if __name__ == '__main__':
    args = parse_args()
    # Generate old and new playbooks for all rules in datastream
    cmd = ['oscap', 'xccdf', 'generate', 'fix', '--profile', '(all)', '--fix-type', 'ansible']
    subprocess.run(cmd + ['--output', 'old.yml', args.old], check=True)
    subprocess.run(cmd + ['--output', 'new.yml', args.new], check=True)

    with open('old.yml', 'r') as old_yaml, open('new.yml', 'r') as new_yaml:
        old_playbook = yaml.safe_load(old_yaml)
        new_playbook = yaml.safe_load(new_yaml)
    # Get only shell commands
    old_shell_modules = get_shell_tasks(old_playbook[0]['tasks'])
    new_shell_modules = get_shell_tasks(new_playbook[0]['tasks'])

    diff = set(new_shell_modules) - set(old_shell_modules)
    if diff:
        print(f"Changes in Ansible shell module have been found:")
        print("\n".join(diff))

    Path.unlink('old.yml')
    Path.unlink('new.yml')
    exit(0)
