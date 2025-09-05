#!/usr/bin/python3

import argparse

import oval_tester


def main():
    parser = argparse.ArgumentParser(
        description="Test Jinja macros that Generate OVAL")
    parser.add_argument(
        "--verbose", action="store_true", default=False,
        help="Show results of each test case")
    args = parser.parse_args()
    tester = oval_tester.OVALTester(args.verbose)

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
        "parameter, single value, trailing comment, multi_value enabled",
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
        "multiple values, multi_value enabled, value in the middle",
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
        "multiple values, multi_value enabled, value is the last",
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
    tester.test(
        "SHELL commented out",
        r"""{{{ oval_check_shell_file(
            path='CONFIG_FILE',
            parameter='SHELL',
            value='/bin/bash',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
        ) }}}""",
        "# SHELL=/bin/bash\n",
        "false"
    )
    tester.test(
        "SHELL correct",
        r"""{{{ oval_check_shell_file(
            path='CONFIG_FILE',
            parameter='SHELL',
            value='/bin/bash',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
        ) }}}""",
        " SHELL=/bin/bash\n",
        "true"
    )
    tester.test(
        "SHELL single-quoted",
        r"""{{{ oval_check_shell_file(
            path='CONFIG_FILE',
            parameter='SHELL',
            value='/bin"/bash',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
        ) }}}""",
        " SHELL='/bin\"/bash'\n",
        "true"
    )
    tester.test(
        "SHELL double-quoted",
        r"""{{{ oval_check_shell_file(
            path='CONFIG_FILE',
            parameter='SHELL',
            value='  /bin/bash',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
        ) }}}""",
        """ SHELL="  /bin/bash"\n""",
        "true"
    )
    tester.test(
        "SHELL unwanted double-quoted",
        r"""{{{ oval_check_shell_file(
            path='CONFIG_FILE',
            parameter='SHELL',
            value='  /bin/bash',
            no_quotes=true,
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
        ) }}}""",
        """ SHELL="  /bin/bash"\n""",
        "false"
    )
    tester.test(
        "SHELL unwanted single-quoted",
        r"""{{{ oval_check_shell_file(
            path='CONFIG_FILE',
            parameter='SHELL',
            value='/bin"/bash',
            no_quotes=true,
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
        ) }}}""",
        " SHELL='/bin\"/bash'\n",
        "false"
    )
    tester.test(
        "SHELL double-quoted spaced",
        r"""{{{ oval_check_shell_file(
            path='CONFIG_FILE',
            parameter='SHELL',
            value='/bin/bash',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
        ) }}}""",
        """ SHELL= "/bin/bash"\n""",
        "false"
    )
    tester.test(
        "SHELL bad_var_case",
        r"""{{{ oval_check_shell_file(
            path='CONFIG_FILE',
            parameter='SHELL',
            value='/bin/bash',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
        ) }}}""",
        """ Shell="/bin/bash"\n""",
        "false"
    )
    tester.test(
        "SHELL bad_value_case",
        r"""{{{ oval_check_shell_file(
            path='CONFIG_FILE',
            parameter='SHELL',
            value='/bin/bash',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
        ) }}}""",
        """ SHELL="/bin/Bash"\n""",
        "false"
    )
    tester.test(
        "SHELL badly quoted",
        r"""{{{ oval_check_shell_file(
            path='CONFIG_FILE',
            parameter='SHELL',
            value='/bin/bash',
            missing_parameter_pass=false,
            application='',
            multi_value=false,
            missing_config_file_fail=false,
        ) }}}""",
        """ SHELL="/bin/bash'\n""",
        "false"
    )

    tester.finish()


if __name__ == "__main__":
    main()
