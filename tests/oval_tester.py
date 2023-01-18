#!/usr/bin/python3

from __future__ import print_function

import os
import re
import shutil
import subprocess
import sys
import tempfile

import ssg.build_ovals
import ssg.constants
import ssg.jinja
import ssg.oval
import ssg.rules
import ssg.utils
import ssg.yaml
import ssg.build_yaml
import ssg.rule_yaml
import ssg.id_translate


class OVALTester(object):
    def __init__(self, verbose):
        self.mock_env_yaml = {"rule_id": "test"}
        self.result = True
        self.verbose = verbose

    def _get_result(self, oscap_output):
        pattern = re.compile(
            r"^Definition oval:[A-Za-z0-9_\-\.]+:def:[1-9][0-9]*: (\w+)$")
        for line in oscap_output.splitlines():
            matched = pattern.match(line)
            if matched:
                return matched.group(1)
        return None

    def _create_config_file(self, config_file_content, tmp_dir):
        config_file_path = os.path.join(tmp_dir, "config")
        if config_file_content:
            with open(config_file_path, "w") as f:
                f.write(config_file_content)
        return config_file_path

    def _create_oval(self, oval_content, config_file_path, tmp_dir):
        oval_content = oval_content.replace("CONFIG_FILE", config_file_path)
        shorthand_path = os.path.join(tmp_dir, "shorthand")
        with open(shorthand_path, "w") as f:
            f.write(oval_content)
        oval_path = os.path.join(tmp_dir, "oval.xml")
        ssg.build_ovals.expand_shorthand(
            shorthand_path, oval_path, self.mock_env_yaml)
        return oval_path

    def _evaluate_oval(self, oval_path):
        results_path = oval_path + ".results.xml"
        oscap_command = [
            "oscap", "oval", "eval", "--results", results_path, oval_path]
        oscap_process = subprocess.Popen(
            oscap_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        oscap_stdout, oscap_stderr = oscap_process.communicate()
        def_result = self._get_result(oscap_stdout.decode("utf-8"))
        return def_result, results_path

    def test(self, description, oval_content, config_file_content,
             expected_result):
        """
        Execute a test.
        description: a very short description to be displayed in test output
        oval_content: content of the OVAL shorthand file written in a way you
                      write OVALs in SSG rules (not a valid OVAL)
        config_file_content: content of the text configuration file that the
                             OVAL will check
        expected_result: expected result of evaluation of the OVAL definition
        """
        try:
            tmp_dir = tempfile.mkdtemp()
            config_file_path = self._create_config_file(
                config_file_content, tmp_dir)
            oval_path = self._create_oval(
                oval_content, config_file_path, tmp_dir)
            result, results_path = self._evaluate_oval(oval_path)
            msg = ("OVAL Definition was evaluated as %s, but expected result "
                   "is %s.") % (result, expected_result)
            assert result == expected_result, msg
            if self.verbose:
                print("Test: %s: PASS" % (description))
            self.result = self.result and True
        except AssertionError as e:
            if self.verbose:
                print("Test: %s: FAIL" % (description))
                print("    " + str(e))
            self.result = False
        finally:
            shutil.rmtree(tmp_dir)

    def finish(self):
        """
        Exit test with an appropriate return code.
        """
        sys.exit(0 if self.result else 1)
