#!/usr/bin/python3

import argparse
import os
import sys
from types import SimpleNamespace
from yamlpath import Processor
from yamlpath import YAMLPath
from yamlpath.common import Parsers
from yamlpath.exceptions import YAMLPathException
from yamlpath.wrappers import ConsolePrinter


def parse_command_line_args():
    parser = argparse.ArgumentParser(
        description="Checks if an Ansible Playbook removes a file and then adds it again.")
    parser.add_argument("--ansible_dir", required=True,
                        help="Directory containing Ansible Playbooks")
    args = parser.parse_args()
    return args


def check_playbook_file_removed_and_added(playbook_path):
    playbook_ok = True

    yaml_parser = Parsers.get_yaml_editor()

    logging_args = SimpleNamespace(quiet=False, verbose=False, debug=False)
    log = ConsolePrinter(logging_args)

    # Find every path removed by a file Task (also matches tasks within blocks)
    files_absent_string = "tasks.**.file[state=absent][parent()].path"
    files_absent_yamlpath = YAMLPath(files_absent_string)
    path_editing_tasks_yamlpath = ""

    log.info("Info: Evaluating playbook '{}'".format(playbook_path))
    (yaml_data, doc_loaded) = Parsers.get_yaml_data(yaml_parser, log, playbook_path)
    if not doc_loaded:
        # There was an issue loading the file; an error message has already been
        # printed via ConsolePrinter.
        return False

    processor = Processor(log, yaml_data)
    try:
        for node in processor.get_nodes(files_absent_yamlpath, mustexist=False):
            path = str(node)
            # 'node' is a NodeCoords.
            if path == 'None':
                continue
            elif "{{" in path:
                # Identified path is a Jinja expression, unfortunately there is no easy way to get
                # the actual path without making this test very complicated
                continue

            # Check if this paths is used in any of the following ansible modules
            ansible_modules = ["lineinfile", "blockinfile", "copy"]
            path_editing_tasks_string = "tasks.**.[.=~/{modules}/][*='{path}'][parent()].name"
            path_editing_tasks_yamlpath = YAMLPath(path_editing_tasks_string.format(
                modules="|".join(ansible_modules),
                path=node)
                )
            for task in processor.get_nodes(path_editing_tasks_yamlpath, mustexist=False):
                log.info("Error: Task '{}' manipulates a file that is removed by another task"
                         .format(task))
                playbook_ok = False
    except YAMLPathException as ex:
        no_file_msg = ("Cannot add PathSegmentTypes.TRAVERSE subreference to lists at 'None' "
                       "in '{}'.")
        if str(ex) == no_file_msg.format(files_absent_string):
            log.info("Info: Playbook {} has no 'file' tasks.".format(playbook_path))
        elif path_editing_tasks_yamlpath and str(ex) == no_file_msg.format(
                path_editing_tasks_yamlpath):
            log.info("Info: Playbook {} has no '{}' tasks.".format(
                playbook_path, " ".join(ansible_modules)))
        else:
            log.info("Error: {}.".format(ex))

    return playbook_ok


def main():
    args = parse_command_line_args()

    all_playbooks_ok = True
    for dir_item in os.listdir(args.ansible_dir):
        if dir_item.endswith(".yml"):
            playbook_path = os.path.join(args.ansible_dir, dir_item)

            if not check_playbook_file_removed_and_added(playbook_path):
                all_playbooks_ok = False

    if not all_playbooks_ok:
        sys.exit(1)


if __name__ == "__main__":
    main()
