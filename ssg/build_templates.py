from __future__ import absolute_import
from __future__ import print_function

import os
import sys

templates_dir = os.path.join(os.path.dirname(__file__), "..", "shared", "templates")
sys.path.append(templates_dir)
from template_common import ActionType, TEMPLATED_LANGUAGES

from create_accounts_password import AccountsPasswordGenerator
from create_kernel_modules_disabled import KernelModulesDisabledGenerator
from create_mounts import MountsGenerator
from create_mount_options import MountOptionsGenerator
from create_package_installed import PackageInstalledGenerator
from create_package_removed import PackageRemovedGenerator
from create_permissions import PermissionGenerator
from create_selinux_booleans import SEBoolGenerator
from create_services_disabled import ServiceDisabledGenerator
from create_services_enabled import ServiceEnabledGenerator
from create_timers_enabled import TimerEnabledGenerator
from create_sysctl import SysctlGenerator
from create_audit_rules_dac_modification import AuditRulesDacModificationGenerator
from create_audit_rules_unsuccessful_file_modification import AuditRulesUnsuccessfulFileModificationGenerator
from create_audit_rules_unsuccessful_file_modification_detailed import ARUFMDetailedGenerator
from create_audit_rules_file_deletion_events import AuditRulesFileDeletionEventsGenerator
from create_audit_rules_login_events import AuditRulesLoginEventsGenerator
from create_audit_rules_privileged_commands import AuditRulesPrivilegedCommandsGenerator
from create_audit_rules_usergroup_modification import AuditRulesUserGroupModificationGenerator
from create_audit_rules_execution import AuditRulesExecutionGenerator
from create_audit_rules_path_syscall import AuditRulesPathSyscallGenerator
from create_grub2_bootloader_argument import GRUB2BootloaderArgumentGenerator
from create_ocp_service_runtime_config import OCPServiceRuntimeConfigGenerator
from create_sshd_lineinfile import SSHDLineinfileGenerator


class Builder(object):
    """
    Class for building all templated content for a given product.

    To generate, pass the combined build_config_yaml and product_yaml into
    the constructor, use set_langs to set output languages, specify the
    input, output, and shared directories, and then call the one of the
    following functions:

        list_inputs() -- to generate a list of inputs into the build process
        list_outputs() -- to generate a list of outputs from the build process
        build() -- to perform a build
    """

    def __init__(self, env_yaml):
        self.input_dir = None
        self.template_dir = None
        self.csv_dir = None
        self.output_dir = None
        self.ssg_shared = ""
        self.env_yaml = env_yaml

        self.script_dict = {
            "sysctl_values.csv":                SysctlGenerator(),
            "services_disabled.csv":            ServiceDisabledGenerator(),
            "services_enabled.csv":             ServiceEnabledGenerator(),
            "timers_enabled.csv":               TimerEnabledGenerator(),
            "packages_installed.csv":           PackageInstalledGenerator(),
            "packages_removed.csv":             PackageRemovedGenerator(),
            "kernel_modules_disabled.csv":      KernelModulesDisabledGenerator(),
            "file_dir_permissions.csv":         PermissionGenerator(),
            "accounts_password.csv":            AccountsPasswordGenerator(),
            "mounts.csv":                       MountsGenerator(),
            "mount_options.csv":                MountOptionsGenerator(),
            "selinux_booleans.csv":             SEBoolGenerator(),
            "audit_rules_dac_modification.csv": AuditRulesDacModificationGenerator(),
            "audit_rules_unsuccessful_file_modification.csv":   AuditRulesUnsuccessfulFileModificationGenerator(),
            "audit_rules_unsuccessful_file_modification_detailed.csv":   ARUFMDetailedGenerator(),
            "audit_rules_file_deletion_events.csv":  AuditRulesFileDeletionEventsGenerator(),
            "audit_rules_login_events.csv":  AuditRulesLoginEventsGenerator(),
            "audit_rules_privileged_commands.csv":  AuditRulesPrivilegedCommandsGenerator(),
            "audit_rules_usergroup_modification.csv":  AuditRulesUserGroupModificationGenerator(),
            "audit_rules_execution.csv":        AuditRulesExecutionGenerator(),
            "audit_rules_path_syscall.csv":        AuditRulesPathSyscallGenerator(),
            "grub2_bootloader_argument.csv":        GRUB2BootloaderArgumentGenerator(),
            "ocp_service_runtime_config.csv":        OCPServiceRuntimeConfigGenerator(),
            "sshd_lineinfile.csv":        SSHDLineinfileGenerator(),
        }
        self.langs = TEMPLATED_LANGUAGES
        utils_dir = os.path.dirname(os.path.realpath(__file__))
        root_dir = os.path.join(utils_dir, "..", "..")
        self.shared_templates_dir = \
            os.path.join(root_dir, "shared", "templates")

    def set_langs(self, langs):
        """
        Set the languages to be generated for the given template
        """
        self.langs = langs

    def set_input_dir(self, input_dir):
        """
        Specifies the input directory to find templated information in
        """
        self.input_dir = input_dir
        self.template_dir = input_dir
        self.csv_dir = os.path.join(input_dir, "csv")

    def _get_csv_list(self):
        """
        Returns a list containing all CSV files from the internal CSV
        directory.
        """
        csvs = []

        if not os.path.isdir(self.csv_dir):
            return []

        files = os.listdir(self.csv_dir)

        for file_ in files:
            # skip non csv files
            if not file_.endswith(".csv"):
                continue

            # skip empty files
            filepath = os.path.join(self.csv_dir, file_)
            if os.stat(filepath).st_size == 0:
                continue

            csvs.append(file_)

        return csvs

    def _get_generator_for_csv(self, csv_filename):
        """
        For a given CSV file, return the corresponding template generator.

        Exits if no corresponding template generator exists.
        """
        try:
            return self.script_dict[csv_filename]

        except KeyError:
            sys.stderr.write(
                "Cannot find the associated generator class for {0}\n"
                .format(csv_filename)
            )
            sys.exit(1)

    def _deduplicate(self, files):
        """
        Returns the deduplicated set of input files.
        """
        return set(os.path.realpath(file_) for file_ in files)

    def build(self):
        """
        Builds all template files for the specified languages, writing
        the output to the correct build directories.
        """

        for lang in self.langs:
            dir_ = os.path.join(self.output_dir, lang)
            if not os.path.exists(dir_):
                os.makedirs(dir_)

        for csv_filename in self._get_csv_list():
            generator = self._get_generator_for_csv(csv_filename)
            csv_filepath = os.path.join(self.csv_dir, csv_filename)

            generator.reset()
            generator.env_yaml = self.env_yaml
            generator.output_dir = self.output_dir
            generator.action = ActionType.BUILD
            generator.product_input_dir = self.template_dir
            generator.shared_dir = self.ssg_shared

            for lang in self.langs:
                generator.csv_map(csv_filepath, language=lang)

    def get_file_list(self, action):
        """
        For a given action (INPUT or OUTPUT), get the list of
        files associated with building the templated content for
        all languages.

        Returns a set of all such files.
        """
        assert(action in [ActionType.INPUT, ActionType.OUTPUT])

        list_ = []
        if action == ActionType.INPUT:
            pass

        for csv in self._get_csv_list():
            csv_filepath = os.path.join(self.csv_dir, csv)
            generator = self._get_generator_for_csv(csv)

            if action == ActionType.INPUT:
                list_.append(csv_filepath)

            generator.reset()
            generator.env_yaml = self.env_yaml
            generator.output_dir = self.output_dir
            generator.action = action
            generator.product_input_dir = self.template_dir
            generator.shared_dir = self.ssg_shared

            for lang in self.langs:
                generator.csv_map(csv_filepath, language=lang)

            list_.extend(generator.files)

        return self._deduplicate(list_)

    def list_inputs(self):
        """
        Write the list of input files to STDOUT.
        """
        for file_ in self.get_file_list(ActionType.INPUT):
            print(file_)

    def list_outputs(self):
        """
        Write the list of output files to STDOUT.
        """
        for file_ in self.get_file_list(ActionType.OUTPUT):
            print(file_)
