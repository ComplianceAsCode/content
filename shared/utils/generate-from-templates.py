#!/usr/bin/python

import subprocess
import os
import sys
import argparse

templates_dir = os.path.join(os.path.dirname(__file__), "..", "templates")
sys.path.append(templates_dir)
from template_common import ExitCodes

class Builder(object):
    def __init__(self):
        self.input_dir = None
        self.output_dir = None
        self.ssg_shared = ""

        self.script_dict = {
            "sysctl_values.csv":            "create_sysctl.py",
            "services_disabled.csv":        "create_services_disabled.py",
            "services_enabled.csv":         "create_services_enabled.py",
            "packages_installed.csv":       "create_package_installed.py",
            "packages_removed.csv":         "create_package_removed.py",
            "kernel_modules_disabled.csv":  "create_kernel_modules_disabled.py",
            "file_dir_permissions.csv":     "create_permission.py",
            "accounts_password.csv":        "create_accounts_password.py",
            "mount_options.csv":            "create_mount_options.py",
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

    def set_ssg_shared(self, shared):
        self.ssg_shared = shared

    def build(self):
        for lang in self.langs:
            dir_ = self._output_dir_for_lang(lang)
            if not os.path.exists(dir_):
                os.makedirs(dir_)

        # Build scripts for multiple OVAL versions.
        # At first for the oldest OVAL, then newer and newer
        # this will allow to override older implementation
        # with a never one.
        for oval in self.supported_ovals:
            self._set_current_oval(oval)

            for csv_filename in self._get_csv_list():
                script = self._get_script_for_csv(csv_filename)

                csv_filepath = os.path.join(self._get_csv_dir(), csv_filename)
                self._run_script(script, csv_filepath)

    def list_inputs(self):
        for file_ in self.get_input_list():
            print(file_)

    def list_outputs(self):
        for file_ in self.get_output_list():
            print(file_)

    def get_input_list(self):
        list_ = []

        for oval in self.supported_ovals:
            self._set_current_oval(oval)

            csv_dir = self._get_csv_dir()
            for csv in self._get_csv_list():
                csv_filepath = os.path.join(csv_dir, csv)
                script_filepath = self._get_script_for_csv(csv)

                list_.append(csv_filepath)
                list_.append(script_filepath)

                for lang in self.langs:
                    files_list = self._read_io_files_list(
                        script_filepath, csv_filepath, lang, "list-inputs"
                    )
                    list_.extend(files_list)

        return self._deduplicate(list_)

    def get_output_list(self):
        list_ = []

        for oval in self.supported_ovals:
            self._set_current_oval(oval)

            csv_dir = self._get_csv_dir()
            for csv in self._get_csv_list():
                csv_filepath = os.path.join(csv_dir, csv)
                script_filepath = self._get_script_for_csv(csv)

                for lang in self.langs:
                    files_list = self._read_io_files_list(
                        script_filepath, csv_filepath, lang, "list-outputs"
                    )
                    list_.extend(files_list)

        return self._deduplicate(list_)

    def set_output_dir(self, output_dir):
        self.output_dir = output_dir

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

    def _get_script_for_csv(self, csv_filename):
        try:
            script_name = self.script_dict[csv_filename]
            full_path = os.path.join(self.shared_templates_dir, script_name)
            return full_path

        except KeyError:
            sys.stderr.write(
                "Cannot find associated build script for {0}\n"
                .format(csv_filename)
            )
            sys.exit(1)

    def _output_dir_for_lang(self, lang):
        return os.path.join(self.output_dir, lang)

    def _run_script(self, script, csv_filepath):
        for lang in self.langs:
            sp = self._create_subprocess(
                script=script, csv=csv_filepath, lang=lang, action="build",
                print_args=True
            )
            self._subprocess_check(sp)

    def _read_io_files_list(self, script, csv, lang, action):
        sp = self._create_subprocess(script, csv, lang, action)
        return self._get_list_from_subprocess(sp)

    def _create_subprocess(self, script, csv, lang, action, print_args=False):
        args= [
            "python", script,
            "--csv", csv,
            "--lang", lang,
            "--input", self._get_template_dir(),
            "--shared", self.ssg_shared,
            "--output", self.output_dir,
            action
        ]
        if print_args:
            sys.stderr.write(" ".join(args) + "\n")
        return subprocess.Popen(
                args,
                stdout = subprocess.PIPE,
                stderr = subprocess.PIPE
        )

    def _subprocess_check(self, subprocess):
        subprocess.wait()
        no_error_codes = [
            ExitCodes.OK, ExitCodes.NO_TEMPLATE, ExitCodes.UNKNOWN_TARGET
        ]
        if subprocess.returncode in no_error_codes:
            pass
        else:
            comm = subprocess.communicate()
            raise RuntimeError("Process returned: %s"
                               % (
                                   comm[0].decode("utf-8") +
                                   comm[1].decode("utf-8")
                                  ))

    def _get_list_from_subprocess(self, subprocess):
        self._subprocess_check(subprocess)
        text = subprocess.communicate()[0].decode("utf-8")
        return [os.path.abspath(line) for line in text.split("\n") if line]

    def _deduplicate(self, files):
        return set(os.path.realpath(file_) for file_ in files)


if __name__ == "__main__":
    builder = Builder()
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

    if args.language is not None:
        builder.set_langs([args.language])

    builder.set_input_dir(args.input)
    builder.set_output_dir(args.output)
    builder.set_ssg_shared(args.shared)

    if args.oval_version == "oval_5.10":
        builder.supported_ovals = ["oval_5.10"]

    elif args.oval_version == "oval_5.11":
        builder.supported_ovals = ["oval_5.10", "oval_5.11"]

    else:
        sys.stderr.write("Unknown oval version")
        sys.exit(1)

    func = getattr(builder, args.cmd)
    func()
