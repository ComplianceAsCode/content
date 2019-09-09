import argparse
import csv
import os
import pprint
import re

from ssg.constants import product_directories


def escape_path(path):
    return re.sub('[-\./]', '_', path)

def accounts_password_csv_to_dict(csv_line, csv_data):
    accounts_password = {}
    accounts_password["template"] = "package_installed"

    variable = csv_line[0]
    rule_id = f"accounts_password_pam_{variable}"

    operation = csv_line[1]

    # Only credit related variables allow negative values
    sign = "-?" if variable.endswith("credit") else ""

    accounts_password["VARIABLE"] = variable
    accounts_password["OPERATION"] = operation
    accounts_password["SIGN"] = sign
    csv_data[rule_id] = accounts_password
    return accounts_password

def audit_rules_execution_csv_to_dict(csv_line, csv_data):
    audit_rules_execution = {}
    audit_rules_execution["template"] = "audit_rules_privileged_commands"

    path = csv_line[0]
    name = escape_path(os.path.basename(path))
    rule_id = f"audit_rules_execution_{name}"

    # create_audit_rules_execution.py escapes the '/' when generating the OVAL
    # This is not actually necessary
    audit_rules_execution["PATH"] = path
    audit_rules_execution["NAME"] = name

    audit_rules_execution["ID"] = f"audit_rules_execution_{name}"
    audit_rules_execution["TITLE"] = f"Record Any Attempts to Run {name}"
    csv_data[rule_id] = audit_rules_execution
    return audit_rules_execution

def audit_rules_privileged_commands_csv_to_dict(csv_line, csv_data):
    audit_rules_privileged_commands = {}
    audit_rules_privileged_commands["template"] = "audit_rules_privileged_commands"

    path = csv_line[0]
    name = escape_path(os.path.basename(path))
    rule_id = f"audit_rules_privileged_commands_{name}"

    # create_audit_rules_privileged_commands.py escapes the '/' when generating the OVAL
    # This is not actually necessary
    audit_rules_privileged_commands["PATH"] = path
    audit_rules_privileged_commands["NAME"] = name

    audit_rules_privileged_commands["ID"] = f"audit_rules_privileged_commands_{name}"
    audit_rules_privileged_commands["TITLE"] = f"Ensure auditd Collects Information on the Use of Privileged Commands - {name}"
    csv_data[rule_id] = audit_rules_privileged_commands
    return audit_rules_privileged_commands

def audit_rules_dac_modification_csv_to_dict(csv_line, csv_data):
    audit_rules_dac_modification = {}
    audit_rules_dac_modification["template"] = "audit_rules_dac_modification"

    attr = csv_line[0]
    rule_id = f"audit_rules_dac_modification_{attr}"

    audit_rules_dac_modification["ATTR"] = attr
    csv_data[rule_id] = audit_rules_dac_modification
    return audit_rules_dac_modification

def audit_rules_file_deletion_events_csv_to_dict(csv_line, csv_data):
    audit_rules_file_deletion_events = {}
    audit_rules_file_deletion_events["template"] = "audit_rules_file_deletion_events"

    name = csv_line[0]
    rule_id = f"audit_rules_file_deletion_events_{name}"

    audit_rules_file_deletion_events["NAME"] = name
    csv_data[rule_id] = audit_rules_file_deletion_events
    return audit_rules_file_deletion_events

def audit_rules_login_events_csv_to_dict(csv_line, csv_data):
    audit_rules_login_events = {}
    audit_rules_login_events["template"] = "audit_rules_login_events"

    path = csv_line[0]
    name = escape_path(os.path.basename(path))
    rule_id = f"audit_rules_login_events_{name}"

    audit_rules_login_events["PATH"] = path
    audit_rules_login_events["NAME"] = name
    csv_data[rule_id] = audit_rules_login_events
    return audit_rules_login_events

def audit_rules_path_syscall_csv_to_dict(csv_line, csv_data):
    audit_rules_path_syscall = {}
    audit_rules_path_syscall["template"] = "audit_rules_path_syscall"

    path = csv_line[0]
    syscall = csv_line[1]
    arg_pos = csv_line[2]
    # remove root slash made into '_'
    path_id = escape_path(path)[1:]
    rule_id = f"audit_rules_{path_id}_{syscall}"

    audit_rules_path_syscall["PATH"] = path
    audit_rules_path_syscall["PATHID"] = path_id
    audit_rules_path_syscall["SYSCALL"] = syscall
    audit_rules_path_syscall["POS"] = arg_pos
    csv_data[rule_id] = audit_rules_path_syscall
    return audit_rules_path_syscall

def audit_rules_unsuccessful_file_modification_csv_to_dict(csv_line, csv_data):
    audit_rules_unsuccessful_file_modification  = {}
    audit_rules_unsuccessful_file_modification["template"] = "audit_rules_unsuccessful_file_modification"

    name = csv_line[0]
    rule_id = f"audit_rules_unsuccessful_file_modification_{name}"

    audit_rules_unsuccessful_file_modification ["NAME"] = name
    csv_data[rule_id] = audit_rules_unsuccessful_file_modification
    return audit_rules_unsuccessful_file_modification

def audit_rules_unsuccessful_file_modification_detailed_csv_to_dict(csv_line, csv_data):
    audit_rules_unsuccessful_file_modification_detailed = {}

    syscall = csv_line[0]
    arg_pos = csv_line[1]

    template_base = "audit_rules_unsuccessful_file_modification_"
    template_suffixes = ["o_creat",
                "o_trunc_write",
                "rule_order",
                ]

    audit_rules_unsuccessful_file_modification_detailed["SYSCALL"] = syscall
    audit_rules_unsuccessful_file_modification_detailed["POS"] = arg_pos

    for suffix in template_suffixes:
        audit_rules_unsuccessful_file_modification_detailed["template"] = f"{template_base}{suffix}"
        rule_id = f"{template_base}{syscall}_{suffix}"
        # If a csv line has except-for, it won't be handled correctly
        csv_data[rule_id] = audit_rules_unsuccessful_file_modification_detailed.copy()

    return audit_rules_unsuccessful_file_modification_detailed

def audit_rules_usergroup_modification_csv_to_dict(csv_line, csv_data):
    user_group_modification = {}
    user_group_modification["template"] = "audit_rules_usergroup_modification"

    path = csv_line[0]
    name = escape_path(os.path.basename(path))
    rule_id = f"audit_rules_usergroup_modification_{name}"

    user_group_modification["NAME"] = name
    user_group_modification["PATH"] = path
    csv_data[rule_id] = user_group_modification
    return user_group_modification

def grub2_bootloader_argument_csv_to_dict(csv_line, csv_data):
    grub2_bootloader_argument = {}
    grub2_bootloader_argument["template"] = "grub2_bootloader_argument"

    arg_name= csv_line[0]
    arg_value = csv_line[1]
    rule_id = f"grub2_{arg_name}_argument"

    arg_name_value = f"{arg_name}={arg_value}"
    grub2_bootloader_argument["ARG_NAME"] = arg_name
    grub2_bootloader_argument["ARG_NAME_VALUE"] = arg_name_value
    csv_data[rule_id] = grub2_bootloader_argument
    return grub2_bootloader_argument

def kernel_modules_disabled_csv_to_dict(csv_line, csv_data):
    kernel_modules_disabled = {}
    kernel_modules_disabled["template"] = "kernel_module_disabled"

    kernmod = csv_line[0]
    rule_id = f"kernel_module_{kernmod}_disabled"

    kernel_modules_disabled["KERNMODULE"] = kernmod
    csv_data[rule_id] = kernel_modules_disabled
    return kernel_modules_disabled

def lineinfile_csv_to_dict(csv_line, csv_data, _type):
    lineinfile = {}
    lineinfile["template"] = "{_type}_lineinfile"

    rule_id = csv_line[0]
    parameter = csv_line[1]
    value = csv_line[2]
    if len(csv_line) == 4:
        missing_parameter_pass = csv_line[3]
    else:
        missing_paramteter_pass = "false"

    lineinfile["products"] = "all"
    lineinfile["rule_title"] = f"Rule title of {rule_id}"
    lineinfile["rule_id"] = rule_id
    lineinfile["PARAMETER"] = parameter
    lineinfile["VALUE"] = value
    lineinfile["MISSING_PARAMETER_PASS"] = missing_parameter_pass
    csv_data[rule_id] = lineinfile
    return lineinfile

def auditd_lineinfile_csv_to_dict(csv_line, csv_data):
    return lineinfile_csv_to_dict(csv_line, csv_data, "auditd")

def sshd_lineinfile_csv_to_dict(csv_line, csv_data):
    return lineinfile_csv_to_dict(csv_line, csv_data, "sshd")

def mount_options_csv_to_dict(csv_line, csv_data):
    mount_options = {}
    mount_point = csv_line[0]
    mount_option = csv_line[1]

    template_base = "mount_option"
    mount_has_to_exist = "yes"
    filesystem = ""
    mount_point_type = ""
    if len(csv_line) > 2:
        # When create_fstab_entry_if_needed is in CSV file, load next two values
        mount_has_to_exist = "no"
        filesystem = csv_line[3]
        mount_point_type = csv_line[4]

    point_id = f"{mount_point}"
    if mount_point.startswith("var_"):
        # var_removable_partition -> removable_partitions
        point_id = re.sub(r"^var_(.*)", r"\1s", mount_point)
        rule_id = f"mount_option_{mount_option}_{point_id}"
        mount_options["template"] = f"{template_base}_{point_id}"
    elif mount_point.startswith("/"):
        point_id = escape_path(mount_point)[1:]
        rule_id = f"mount_option_{point_id}_{mount_option}"
        mount_options["template"] = template_base
    else:
        point_id = mount_point
        rule_id = f"mount_option_{mount_option}_{point_id}"
        mount_options["template"] = f"{template_base}_{point_id}"

    # Not all fields will be used by all templates, this is fine,
    # they will just be ignored
    mount_options["MOUNT_HAS_TO_EXIST"] = mount_has_to_exist
    mount_options["FILESYSTEM"] = filesystem
    mount_options["TYPE"] = mount_point_type
    mount_options["MOUNTPOINT"] = mount_point
    mount_options["MOUNTOPTION"] = mount_option
    mount_options["POINTID"] = point_id
    csv_data[rule_id] = mount_options
    return mount_options

def mounts_csv_to_dict(csv_line, csv_data):
    mounts = {}
    mounts["template"] = "mount"

    mountpoint = csv_line[0]
    point_id = escape_path(mountpoint)
    rule_id = f"partition_for{point_id}"

    mounts["MOUNTPOINT"] = mountpoint
    csv_data[rule_id] = mounts
    return mounts

def packages_installed_csv_to_dict(csv_line, csv_data):
    package_installed = {}
    package_installed["template"] = "package_installed"

    pkgname = csv_line[0]
    rule_id = f"package_{pkgname}_installed"

    if len(csv_line) == 2:
        evr = csv_line[1]
    else:
        evr = ""

    package_installed["PKGNAME"] = pkgname
    package_installed["EVR"] = evr
    csv_data[rule_id] = package_installed
    return package_installed

def packages_removed_csv_to_dict(csv_line, csv_data):
    package_removed = {}
    package_removed["template"] = "package_removed"

    pkgname = csv_line[0]
    rule_id = f"package_{pkgname}_removed"

    # Some CSVs have two fields for packages_removed, but
    # create_package_removed.py doesn't use the second field.
    # So just ignore it as well

    package_removed["PKGNAME"] = pkgname
    csv_data[rule_id] = package_removed
    return package_removed

class ProductCSVData(object):
    TEMPLATE_TO_CSV_FORMAT_MAP = {
            "accounts_password.csv": accounts_password_csv_to_dict,
            "audit_rules_execution.csv": audit_rules_execution_csv_to_dict,
            "audit_rules_privileged_commands.csv": audit_rules_privileged_commands_csv_to_dict,
            "audit_rules_dac_modification.csv": audit_rules_dac_modification_csv_to_dict,
            "audit_rules_file_deletion_events.csv": audit_rules_file_deletion_events_csv_to_dict,
            "audit_rules_login_events.csv": audit_rules_login_events_csv_to_dict,
            "audit_rules_path_syscall.csv": audit_rules_path_syscall_csv_to_dict,
            "audit_rules_unsuccessful_file_modification.csv": audit_rules_unsuccessful_file_modification_csv_to_dict,
            "audit_rules_unsuccessful_file_modification_detailed.csv": audit_rules_unsuccessful_file_modification_detailed_csv_to_dict,
            "audit_rules_usergroup_modification.csv": audit_rules_usergroup_modification_csv_to_dict,
            "grub2_bootloader_argument.csv": grub2_bootloader_argument_csv_to_dict,
            "kernel_modules_disabled.csv": kernel_modules_disabled_csv_to_dict,
            "auditd_lineinfile.csv": sshd_lineinfile_csv_to_dict,
            "sshd_lineinfile.csv": auditd_lineinfile_csv_to_dict,
            "mount_options.csv": mount_options_csv_to_dict,
            "mounts.csv": mounts_csv_to_dict,
            "packages_installed.csv": packages_installed_csv_to_dict,
            "packages_removed.csv": packages_removed_csv_to_dict,
            }

    def __init__(self, product, ssg_root):
        self.product = product
        self.ssg_root = ssg_root  # Needed?

        self.csv_dir = os.path.join(ssg_root, product, "templates/csv")
        self.csv_files = self._identify_csv_files(self.csv_dir)

        self.csv_data = self._load_csv_files(self.csv_files)

    def _identify_csv_files(self, csv_dir):
        try:
            # get all CSV files
            product_csvs = [csv_filename for csv_filename in os.listdir(csv_dir)
                            if csv_filename.endswith(".csv")]
        except FileNotFoundError as not_found:
            product_csvs = []
            # double check that exception is on templates/csv directory
            if not_found.filename != csv_dir:
                raise not_found
        return product_csvs

    def _load_csv_files(self, csv_files):
        csv_data = {}
        for csv_filename in csv_files:
            self._load_csv(csv_filename, csv_data)
        return csv_data

    def _load_csv(self, csv_filename, csv_data):
        # Only load CSV for which we know the format
        csv_parser = self.TEMPLATE_TO_CSV_FORMAT_MAP.get(csv_filename, None)
        if not csv_parser:
            return

        with open(os.path.join(self.csv_dir, csv_filename), "r") as csv_f:
            for line in csv.reader(csv_f):
                # Skip empty lines
                if len(line) == 0:
                    continue

                # Skip all comment lines
                if len(line) >= 1 and line[0].startswith('#'):
                    continue

                except_for_language = None
                if "#except-for:" in line[-1]:
                    line[-1], except_for_clause = line[-1].split('#')
                    # There are no cases of except-for for multiple languagues
                    _, except_for_language = except_for_clause.split(':')

                try:
                    # Each CSV file is particular to its template, as a single CSV line can:
                    # - contain data for multiple rules in diferent templates
                    #   (audit_rules_unsuccessful_file_modification_detailed);
                    # A single CSV file can:
                    # - contain data for varying templates (mount_options).
                    # We let the CSV specific parser add the data
                    line_data_dict = csv_parser(line, csv_data)

                    if except_for_language:
                        line_data_dict["except_for"] = except_for_language
                except IndexError as e:
                    print(f"line:{line} in file: {csv_f}")
                    raise e


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("ssg_root", help="Path to root of ssg git directory")

    return p.parse_args()


def main():
    args = parse_args()

    show_data = {}
    templated_content = {}

    # Load all product's CSV data
    for product_name in product_directories:
        product = ProductCSVData(product_name, args.ssg_root)
        templated_content[product_name] = product.csv_data
        show_data[product_name] = product.csv_data

    # Load shared CSV Data as if it were a Product
    product_name = "shared"
    product = ProductCSVData(product_name, args.ssg_root)
    templated_content[product_name] = product.csv_data
    show_data[product_name] = product.csv_data

    # Ilustrate DataStructure
    pprint.pprint(show_data)

    # Normalize loaded CSV Data

    # Walk through benchmark and add data into rule.yml


if __name__ == "__main__":
    main()
