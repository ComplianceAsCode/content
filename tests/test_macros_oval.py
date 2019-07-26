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
    def __init__(self):
        self.mock_env_yaml = {"rule_id": "test"}
        self.result = True

    def _expand_shorthand(self, shorthand_path, oval_path, env_yaml):
        shorthand_file_content = ssg.jinja.process_file_with_macros(
            shorthand_path, env_yaml)
        wrapped_shorthand = (ssg.constants.oval_header +
                             shorthand_file_content +
                             ssg.constants.oval_footer)
        shorthand_tree = ssg.xml.ElementTree.fromstring(
            wrapped_shorthand.encode("utf-8"))

        definitions = ssg.xml.ElementTree.Element(
            "{%s}definitions" % ssg.constants.oval_namespace)
        tests = ssg.xml.ElementTree.Element(
            "{%s}tests" % ssg.constants.oval_namespace)
        objects = ssg.xml.ElementTree.Element(
            "{%s}objects" % ssg.constants.oval_namespace)
        states = ssg.xml.ElementTree.Element(
            "{%s}states" % ssg.constants.oval_namespace)
        variables = ssg.xml.ElementTree.Element(
            "{%s}variables" % ssg.constants.oval_namespace)
        for childnode in shorthand_tree.findall(".//{%s}def-group/*" %
                                                ssg.constants.oval_namespace):
            if childnode.tag is ssg.xml.ElementTree.Comment:
                continue
            elif childnode.tag.endswith("definition"):
                ssg.build_ovals.append(definitions, childnode)
            elif childnode.tag.endswith("_test"):
                ssg.build_ovals.append(tests, childnode)
            elif childnode.tag.endswith("_object"):
                ssg.build_ovals.append(objects, childnode)
            elif childnode.tag.endswith("_state"):
                ssg.build_ovals.append(states, childnode)
            elif childnode.tag.endswith("_variable"):
                ssg.build_ovals.append(variables, childnode)
            else:
                sys.stderr.write(
                    "Warning: Unknown element '%s'\n" % (childnode.tag))

        header = ssg.xml.oval_generated_header("test", "5.11", "1.0")
        skeleton = header + ssg.constants.oval_footer
        root = ssg.xml.ElementTree.fromstring(skeleton.encode("utf-8"))
        root.append(definitions)
        root.append(tests)
        root.append(objects)
        root.append(states)
        if list(variables):
            root.append(variables)
        id_translator = ssg.id_translate.IDTranslator("test")
        root_translated = id_translator.translate(root)

        ssg.xml.ElementTree.ElementTree(root_translated).write(oval_path)

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
        self._expand_shorthand(shorthand_path, oval_path, self.mock_env_yaml)
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
            print("Test: %s: PASS" % (description))
            self.result = self.result and True
        except AssertionError as e:
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


def main():
    tester = OVALTester()

    #######################################################
    # Test cases for whitespace separated files
    #######################################################

    tester.test(
        "correct value",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "speed 100",
        "true"
    )
    tester.test(
        "correct value and a comment",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "speed 100 # be very fast",
        "true"
    )
    tester.test(
        "correct value on a new line",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "\n\n\n\n\n\nspeed 100",
        "true"
    )
    tester.test(
        "correct value separated by a tab",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "speed\t100",
        "true"
    )
    tester.test(
        "wrong value",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "speed 80",
        "false"
    )
    tester.test(
        "wrong value which contains the correct value as a substring",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "speed 1000",
        "false"
    )
    tester.test(
        "commented value",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "# speed 80",
        "false"
    )
    tester.test(
        "missing whitespace",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "speed100",
        "false"
    )
    tester.test(
        "parameter without a value",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "speed ",
        "false"
    )
    tester.test(
        "misspelled parameter with a value",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "sspeed 100",
        "false"
    )
    tester.test(
        "parameter is on a different line than the value",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "speed\n100",
        "false"
    )
    tester.test(
        "multiple empty lines among parameter and value",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "\n\nspeed\n\n\n100\n\n\n\n",
        "false"
    )
    tester.test(
        "parameter with multiple values when multi_value disabled",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "speed 100 50 8",
        "false"
    )
    tester.test(
        "parameter with single value when multi_value enabled",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=true,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "speed 100",
        "true"
    )
    tester.test(
        "parameter with single value and trailing comment when multi_value enabled",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=true,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "speed 100 #comment",
        "true"
    )
    tester.test(
        "parameter with multiple values when multi_value enabled",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=true,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "speed 100 50 8",
        "true"
    )
    tester.test(
        "parameter with multiple values when multi_value enabled, value in the middle",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=true,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "speed abcd 333 100 50 8",
        "true"
    )
    tester.test(
        "parameter with multiple values when multi_value enabled, value is the last",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=true,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "speed 2 4 6 8 10 14 100",
        "true"
    )
    tester.test(
        "parameter with extra newlines, multi_value enabled",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=true,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "speed\n\n100",
        "false"
    )
    tester.test(
        "parameter with multiple values when multi_value enabled, comment",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=true,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "speed 2 4 6 8 10 14 100 # astonishing",
        "true"
    )
    tester.test(
        "multi_value is used and value is a suffix of a value",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=true,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "speed 1001000",
        "false"
    )
    tester.test(
        "parameter with a value commented out",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "speed # 100",
        "false"
    )
    tester.test(
        "missing parameter fails",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "lights on",
        "false"
    )
    tester.test(
        "missing parameter pass",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=true,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "lights on",
        "true"
    )
    tester.test(
        "overwriting",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=true,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        """speed 100
        speed 60""",
        "false"
    )
    tester.test(
        "overwriting commented out",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=true,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        """speed 100
        #speed 60""",
        "true"
    )
    tester.test(
        "config file missing should fail",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=true,
            application='',
            multi_value=false,
            missing_config_file_fail=true,
            section=''
        ) }}}""",
        None,
        "false"
    )
    tester.test(
        "config file missing should pass",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=true,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        None,
        "true"
    )
    tester.test(
        "config file missing should fail due to missing parameter",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=true,
            section=''
        ) }}}""",
        None,
        "false"
    )
    tester.test(
        "config file missing but missing parameter isn't allowed",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]+',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        None,
        "false"
    )

    #######################################################
    # Test cases for equal sign separated files
    #######################################################
    tester.test(
        "correct value, no whitespace",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]*=[ \t]*',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "speed=100",
        "true"
    )
    tester.test(
        "correct value, some spaces in the middle",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]*=[ \t]*',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "speed  =  100",
        "true"
    )
    tester.test(
        "correct value, many spaces everywhere",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]*=[ \t]*',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "    speed  =  100      ",
        "true"
    )
    tester.test(
        "correct value, tabs",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]*=[ \t]*',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "\tspeed\t=\t100",
        "true"
    )
    tester.test(
        "correct value, and a comment",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]*=[ \t]*',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "speed=100 # be very fast",
        "true"
    )
    tester.test(
        "wrong value, and a comment",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]*=[ \t]*',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "speed=800 # be extremely fast",
        "false"
    )
    tester.test(
        "no value, and a comment",
        r"""{{{ oval_check_config_file(
            path='CONFIG_FILE',
            prefix_regex='^[ \t]*',
            parameter='speed',
            separator_regex='[ \t]*=[ \t]*',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
            section=''
        ) }}}""",
        "speed= # 100",
        "false"
    )

    ######################################
    # Test cases for INI files
    ######################################
    tester.test(
        "INI correct value",
        r"""{{{ oval_check_ini_file(
            path='CONFIG_FILE',
            section="vehicle",
            parameter='speed',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
        ) }}}""",
        """[vehicle]
        speed = 100""",
        "true"
    )
    tester.test(
        "INI correct value trailing whitespace",
        r"""{{{ oval_check_ini_file(
            path='CONFIG_FILE',
            section="vehicle",
            parameter='speed',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
        ) }}}""",
        """[vehicle]
        speed = 100               """,
        "true"
    )
    tester.test(
        "INI correct value no whitespace",
        r"""{{{ oval_check_ini_file(
            path='CONFIG_FILE',
            section="vehicle",
            parameter='speed',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
        ) }}}""",
        "[vehicle]\nspeed=100",
        "true"
    )
    tester.test(
        "INI correct value tabs",
        r"""{{{ oval_check_ini_file(
            path='CONFIG_FILE',
            section="vehicle",
            parameter='speed',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
        ) }}}""",
        "[vehicle]\n\tspeed\t=\t100",
        "true"
    )
    tester.test(
        "INI correct value commented out",
        r"""{{{ oval_check_ini_file(
            path='CONFIG_FILE',
            section="vehicle",
            parameter='speed',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
        ) }}}""",
        """[vehicle]
        #speed = 100""",
        "false"
    )
    tester.test(
        "INI section commented out",
        r"""{{{ oval_check_ini_file(
            path='CONFIG_FILE',
            section="vehicle",
            parameter='speed',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
        ) }}}""",
        "#[vehicle]\nspeed = 100",
        "false"
    )
    tester.test(
        "INI correct value among multiple values",
        r"""{{{ oval_check_ini_file(
            path='CONFIG_FILE',
            section="vehicle",
            parameter='speed',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
        ) }}}""",
        """[vehicle]
        color = red
        speed = 100
        doors = 5""",
        "true"
    )
    tester.test(
        "INI correct value among multiple values commented out",
        r"""{{{ oval_check_ini_file(
            path='CONFIG_FILE',
            section="vehicle",
            parameter='speed',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
        ) }}}""",
        """[vehicle]
        color = red
        #speed = 100
        doors = 5""",
        "false"
    )
    tester.test(
        "INI wrong value",
        r"""{{{ oval_check_ini_file(
            path='CONFIG_FILE',
            section="vehicle",
            parameter='speed',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
        ) }}}""",
        """[vehicle]
        speed = 200""",
        "false"
    )
    tester.test(
        "INI wrong value which is a substring",
        r"""{{{ oval_check_ini_file(
            path='CONFIG_FILE',
            section="vehicle",
            parameter='speed',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
        ) }}}""",
        """[vehicle]
        speed = 10000""",
        "false"
    )
    tester.test(
        "INI overwritten",
        r"""{{{ oval_check_ini_file(
            path='CONFIG_FILE',
            section="vehicle",
            parameter='speed',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
        ) }}}""",
        """[vehicle]
        speed = 100
        speed = 200""",
        "false"
    )
    tester.test(
        "INI correct value in a wrong section",
        r"""{{{ oval_check_ini_file(
            path='CONFIG_FILE',
            section="vehicle",
            parameter='speed',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
        ) }}}""",
        """[house]
        speed = 100""",
        "false"
    )
    tester.test(
        "INI section overwritten",
        r"""{{{ oval_check_ini_file(
            path='CONFIG_FILE',
            section="vehicle",
            parameter='speed',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
        ) }}}""",
        "[vehicle]\n[house]\nspeed = 100",
        "false"
    )
    tester.test(
        "INI no section at all",
        r"""{{{ oval_check_ini_file(
            path='CONFIG_FILE',
            section="vehicle",
            parameter='speed',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
        ) }}}""",
        "speed = 100",
        "false"
    )
    tester.test(
        "INI extra newlines",
        r"""{{{ oval_check_ini_file(
            path='CONFIG_FILE',
            section="vehicle",
            parameter='speed',
            value='100',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
        ) }}}""",
        "[vehicle]\nspeed =\n100",
        "false"
    )

    tester.finish()


if __name__ == "__main__":
    main()
