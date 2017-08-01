#!/usr/bin/env python2

import os
import sys
import argparse

templates_dir = os.path.join(os.path.dirname(__file__), "..", "templates")
sys.path.append(templates_dir)
from template_common import ActionType

from create_accounts_password import AccountsPasswordGenerator
from create_kernel_modules_disabled import KernelModulesDisabledGenerator
from create_mount_options import MountOptionsGenerator
from create_package_installed import PackageInstalledGenerator
from create_package_removed import PackageRemovedGenerator
from create_permission import PermissionGenerator
from create_selinux_booleans import SEBoolGenerator
from create_services_disabled import ServiceDisabledGenerator
from create_services_enabled import ServiceEnabledGenerator
from create_sysctl import SysctlGenerator
from create_audit_rules_dac_modification import AuditRulesDacModificationGenerator
from create_audit_rules_unsuccessful_file_modification import AuditRulesUnsuccessfulFileModificationGenerator
from create_audit_rules_file_deletion_events import AuditRulesFileDeletionEventsGenerator
from create_audit_rules_login_events import AuditRulesLoginEventsGenerator
from create_audit_rules_privileged_commands import AuditRulesPrivilegedCommandsGenerator
from create_audit_rules_usergroup_modification import AuditRulesUserGroupModificationGenerator
from create_audit_rules_execution import AuditRulesExecutionGenerator
from create_file_groupowner import FileGroupOwnerGenerator
from create_file_owner import FileOwnerGenerator
from create_file_permissions import FilePermissionsGenerator


class Builder(object):
    def __init__(self):
        self.input_dir = None
        self.output_dir = None
        self.ssg_shared = ""

        self.script_dict = {
            "sysctl_values.csv":                SysctlGenerator(),
            "services_disabled.csv":            ServiceDisabledGenerator(),
            "services_enabled.csv":             ServiceEnabledGenerator(),
            "packages_installed.csv":           PackageInstalledGenerator(),
            "packages_removed.csv":             PackageRemovedGenerator(),
            "kernel_modules_disabled.csv":      KernelModulesDisabledGenerator(),
            "file_dir_permissions.csv":         PermissionGenerator(),
            "accounts_password.csv":            AccountsPasswordGenerator(),
            "mount_options.csv":                MountOptionsGenerator(),
            "selinux_booleans.csv":             SEBoolGenerator(),
            "audit_rules_dac_modification.csv": AuditRulesDacModificationGenerator(),
            "audit_rules_unsuccessful_file_modification.csv":   AuditRulesUnsuccessfulFileModificationGenerator(),
            "audit_rules_file_deletion_events.csv":  AuditRulesFileDeletionEventsGenerator(),
            "audit_rules_login_events.csv":  AuditRulesLoginEventsGenerator(),
            "audit_rules_privileged_commands.csv":  AuditRulesPrivilegedCommandsGenerator(),
            "audit_rules_usergroup_modification.csv":  AuditRulesUserGroupModificationGenerator(),
            "audit_rules_execution.csv":        AuditRulesExecutionGenerator(),
            "file_groupowner.csv":              FileGroupOwnerGenerator(),
            "file_owner.csv":                   FileOwnerGenerator(),
            "file_permissions.csv":             FilePermissionsGenerator(),
        }
        self.supported_ovals = ["oval_5.10"]
        self.langs = ["bash", "ansible", "oval", "anaconda", "puppet"]
        utils_dir = os.path.dirname(os.path.realpath(__file__))
        root_dir = os.path.join(utils_dir, "..", "..")
        self.shared_templates_dir = \
            os.path.join(root_dir, "shared", "templates")

        self.current_oval = "oval_5.10"

    def set_langs(self, langs):
        self.langs = langs

    def set_input_dir(self, input_dir):
        self.input_dir = input_dir
        self.templates_dirs = {
            "oval_5.10": self.input_dir,
            "oval_5.11": os.path.join(self.input_dir, "oval_5.11_templates")
        }

        self.csv_dirs = {
            "oval_5.10": os.path.join(self.input_dir, "csv"),
            "oval_5.11": os.path.join(self.input_dir, "csv", "oval_5.11"),
        }

    def _set_current_oval(self, oval):
        self.current_oval = oval

    def _get_template_dir(self):
        return self.templates_dirs[self.current_oval]

    def _get_csv_dir(self):
        return self.csv_dirs[self.current_oval]

    def _get_csv_list(self):
        dir_ = self._get_csv_dir()

        csvs = []

        try:
            files = os.listdir(dir_)
        except OSError:
            return []

        for file_ in files:
            # skip non csv files
            if not file_.endswith(".csv"):
                continue

            # skip empty files
            filepath = os.path.join(dir_, file_)
            if os.stat(filepath).st_size == 0:
                continue

            csvs.append(file_)

        return csvs

    def _get_generator_for_csv(self, csv_filename):
        try:
            return self.script_dict[csv_filename]

        except KeyError:
            sys.stderr.write(
                "Cannot find the associated generator class for {0}\n"
                .format(csv_filename)
            )
            #sys.exit(1)

    def _deduplicate(self, files):
        return set(os.path.realpath(file_) for file_ in files)

    def build(self):
        for lang in self.langs:
            dir_ = os.path.join(self.output_dir, lang)
            if not os.path.exists(dir_):
                os.makedirs(dir_)

        # Build scripts for multiple OVAL versions.
        # At first for the oldest OVAL, then newer and newer
        # this will allow to override older implementation
        # with a never one.
        for oval in self.supported_ovals:
            self._set_current_oval(oval)

            csv_dir = self._get_csv_dir()
            for csv_filename in self._get_csv_list():
                generator = self._get_generator_for_csv(csv_filename)
                csv_filepath = os.path.join(csv_dir, csv_filename)

                generator.reset()
                generator.output_dir = self.output_dir
                generator.action = ActionType.BUILD
                generator.product_input_dir = self._get_template_dir()
                generator.shared_dir = self.ssg_shared

                for lang in self.langs:
                    generator.csv_map(csv_filepath, language=lang)

    def get_file_list(self, action):
        assert(action in [ActionType.INPUT, ActionType.OUTPUT])

        list_ = []
        if action == ActionType.INPUT:
            pass

        for oval in self.supported_ovals:
            self._set_current_oval(oval)

            csv_dir = self._get_csv_dir()
            for csv in self._get_csv_list():
                csv_filepath = os.path.join(csv_dir, csv)
                generator = self._get_generator_for_csv(csv)

                if action == ActionType.INPUT:
                    list_.append(csv_filepath)

                generator.reset()
                generator.output_dir = self.output_dir
                generator.action = action
                generator.product_input_dir = self._get_template_dir()
                generator.shared_dir = self.ssg_shared

                for lang in self.langs:
                    generator.csv_map(csv_filepath, language=lang)

                list_.extend(generator.files)

        return self._deduplicate(list_)

    def list_inputs(self):
        for file_ in self.get_file_list(ActionType.INPUT):
            print(file_)

    def list_outputs(self):
        for file_ in self.get_file_list(ActionType.OUTPUT):
            print(file_)


if __name__ == "__main__":
    p = argparse.ArgumentParser()

    sp = p.add_subparsers(help="actions")

    make_sp = sp.add_parser('build', help="Build remediations")
    make_sp.set_defaults(cmd="build")

    input_sp = sp.add_parser('list-inputs', help="Generate input list")
    input_sp.set_defaults(cmd="list_inputs")

    output_sp = sp.add_parser('list-outputs', help="Generate output list")
    output_sp.set_defaults(cmd="list_outputs")

    p.add_argument('--language', metavar="LANG", default=None,
                   help="Scripts of which language should we generate? "
                   "Default: all.")
    p.add_argument("-i", "--input", action="store", required=True,
                   help="input directory")
    p.add_argument("-o", "--output", action="store", required=True,
                   help="output directory")
    p.add_argument("-s", "--shared", metavar="PATH", required=True,
                   help="Full absolute path to SSG shared directory")
    p.add_argument('--oval_version', action="store", default="oval_5.10",
                   help="oval version")

    args, unknown = p.parse_known_args()
    if unknown:
        sys.stderr.write(
            "Unknown positional arguments " + ",".join(unknown) + ".\n"
        )
        sys.exit(1)

    builder = Builder()
    if args.language is not None:
        builder.set_langs([args.language])

    builder.set_input_dir(args.input)
    builder.output_dir = args.output
    builder.ssg_shared = args.shared

    if args.oval_version == "oval_5.10":
        builder.supported_ovals = ["oval_5.10"]

    elif args.oval_version == "oval_5.11":
        builder.supported_ovals = ["oval_5.10", "oval_5.11"]

    else:
        sys.stderr.write("Unknown oval version")
        sys.exit(1)

    func = getattr(builder, args.cmd)
    func()
