#!/usr/bin/python

import subprocess
import os
import sys
import argparse


class Builder(object):
    def __init__(self):
        self.input_dir = None
        self.output_dir = None
        self.script_dict = {
            "sysctl_values.csv":            "create_sysctl.py",
            "services_disabled.csv":        "create_services_disabled.py",
            "services_enabled.csv":         "create_services_enabled.py",
            "packages_installed.csv":       "create_package_installed.py",
            "packages_removed.csv":         "create_package_removed.py",
            "kernel_modules_disabled.csv":  "create_kernel_modules_disabled.py",
            "file_dir_permissions.csv":     "create_permission.py",
            "accounts_password.csv":        "create_accounts_password.py",
        }
        self.supported_ovals = ["oval_5.10"]
        self.langs = ["bash", "ansible", "oval"]
        utils_dir = os.path.dirname(os.path.realpath(__file__))
        root_dir = os.path.join(utils_dir, "..", "..")
        self.shared_templates_dir = \
            os.path.join(root_dir, "shared", "templates")

        self.current_oval = "oval_5.10"

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

    def build(self):
        for lang in self.langs:
            self._mkdir_recursive(self._output_dir_for_lang(lang))

        for oval in self.supported_ovals:
            self._set_current_oval(oval)

            for csv_filename in self._get_csv_list():
                script = self._get_script_for_csv(csv_filename)

                csv_filepath = os.path.join(self._get_csv_dir(), csv_filename)
                sys.stderr.write(
                    "{0}\t{1}\n".format(os.path.realpath(script), csv_filepath)
                )
                self._run_script(script, csv_filepath)

    def input(self):
        for file_ in self.get_input_list():
            print(file_)

    def output(self):
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

                list.append(csv_filepath)
                list.append(script_filepath)

                for lang in self.langs:
                    files_list = self._read_io_files_list(
                        script_filepath, csv_filepath, lang, True
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
                        script_filepath, csv_filepath, lang, False
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

    def _set_environment(func):
        def wrapper(self, *args):
            os.environ["TEMPLATE_DIR"] = self._get_template_dir()
            os.environ["BUILD_DIR"] = self.output_dir

            try:
                return func(self, *args)

            finally:
                del os.environ["TEMPLATE_DIR"]
                del os.environ["BUILD_DIR"]

        return wrapper

    @_set_environment
    def _run_script(self, script, csv_filepath):
        for lang in self.langs:
            sp = subprocess.Popen(
                ["python", script, lang, csv_filepath],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            self._subprocess_check(sp)

    def _mkdir_recursive(self, path):
        if not os.path.exists(path):
            self._mkdir_recursive(os.path.realpath(os.path.dirname(path)))

        if not os.path.exists(path):
            os.mkdir(path)

    @_set_environment
    def _read_io_files_list(self, script, csv, lang, gen_input):
        try:
            if gen_input:
                os.environ["GENERATE_INPUT_LIST"] = "true"
            else:
                os.environ["GENERATE_OUTPUT_LIST"] = "true"

            sp = subprocess.Popen(
                ["python", script, lang, csv],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            return self._get_list_from_subprocess(sp)

        finally:
            del os.environ["GENERATE_INPUT_LIST"]
            del os.environ["GENERATE_OUTPUT_LIST"]

    def _subprocess_check(self, subprocess):
        subprocess.wait()
        if subprocess.returncode in [0, 2, 3]:
            pass
        else:
            raise RuntimeError("Process returned: %s"
                               % (subprocess.communicate()[1].decode("utf-8")))

    def _get_list_from_subprocess(self, subprocess):
        self._subprocess_check(subprocess)
        text = subprocess.communicate()[0].decode("utf-8")
        return [os.path.abspath(line) for line in text.split("\n") if line]

    def _deduplicate(self, files):
        return set(os.path.realpath(file_) for file_ in files)


if __name__ == "__main__":
    builder = Builder()
    p = argparse.ArgumentParser()

    sp = p.add_subparsers(dest='cmd', help="actions")

    make_sp = sp.add_parser('build', help="Build remediations")
    make_sp.set_defaults(cmd="build")

    input_sp = sp.add_parser('input', help="Generate input list")
    input_sp.set_defaults(cmd="input")

    output_sp = sp.add_parser('output', help="Generate output list")
    output_sp.set_defaults(cmd="output")

    p.add_argument('--input', action="store", required=True,
                   help="input directory")
    p.add_argument('--output', action="store", required=True,
                   help="output directory")
    p.add_argument('--oval_version', action="store", default="oval_5.10",
                   help="oval version")

    args, unknown = p.parse_known_args()
    if unknown:
        sys.stderr.write(
            "Unknown positional arguments " + ",".join(unknown) + ".\n"
        )
        sys.exit(1)

    builder.set_input_dir(args.input)
    builder.set_output_dir(args.output)

    if args.oval_version == "oval_5.10":
        builder.supported_ovals = ["oval_5.10"]

    elif args.oval_version == "oval_5.11":
        builder.supported_ovals = ["oval_5.10", "oval_5.11"]

    else:
        sys.stderr.write("Unknown oval version")
        sys.exit(1)

    func = getattr(builder, args.cmd)
    func()
