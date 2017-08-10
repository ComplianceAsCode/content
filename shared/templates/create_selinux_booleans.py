#
# create_selinux_booleans.py
#   automatically generate checks for selinux booleans

import sys
import re

from template_common import FilesGenerator, UnknownTargetError


class SEBoolGenerator(FilesGenerator):
    def generate(self, target, sebool_info):
        sebool_name, sebool_state = sebool_info
        # convert variable name to a format suitable for 'id' tags
        sebool_id = re.sub('[-\.]', '_', sebool_name)
        (sebool_state, sebool_bool) = self._bool_state(sebool_state)
        if not sebool_state:
            pass
        else:
            if target == "oval":
                if sebool_state != "use_var":
                    self.file_from_template(
                        "./template_OVAL_sebool",
                        {
                            "%SEBOOLID%": sebool_id,
                            "%SEBOOL_BOOL%": sebool_bool
                        },
                        "./oval/sebool_{0}.xml", sebool_id)
                else:
                    self.file_from_template(
                        "./template_OVAL_sebool_var",
                        {
                            "%SEBOOLID%": sebool_id
                        },
                        "./oval/sebool_{0}.xml", sebool_id
                    )

            elif target == "bash":
                if sebool_state != "use_var":
                    self.file_from_template(
                        "./template_BASH_sebool",
                        {
                            "%SEBOOLID%": sebool_id,
                            "%SEBOOL_BOOL%": sebool_bool
                        },
                        "./bash/sebool_{0}.sh", sebool_id)
                else:
                    self.file_from_template(
                        "./template_BASH_sebool_var",
                        {
                            "%SEBOOLID%": sebool_id
                        },
                        "./bash/sebool_{0}.sh", sebool_id
                    )

            elif target == "ansible":
                if sebool_state != "use_var":
                    self.file_from_template(
                        "./template_ANSIBLE_sebool",
                        {
                            "%SEBOOLID%": sebool_id,
                            "%SEBOOL_BOOL%": sebool_bool
                        },
                        "./ansible/sebool_{0}.yml", sebool_id)
                else:
                    self.file_from_template(
                        "./template_ANSIBLE_sebool_var",
                        {
                            "%SEBOOLID%": sebool_id
                        },
                        "./ansible/sebool_{0}.yml", sebool_id
                    )

            else:
                raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: " +
               "seboolvariable,seboolstate")

    def _bool_state(self, sebool_state):
        sebool = ""
        sebool_state = re.sub(' ', '', sebool_state)

        if sebool_state == "on" or sebool_state == "enable":
            sebool_state = "enabled"
        elif sebool_state == "off" or sebool_state == "disable":
            sebool_state = "disabled"
        elif sebool_state == "use_var" or sebool_state == "":
            pass
        else:
            print("Error: Invalid SELinux state value: %s" % sebool_state)
            sys.exit()

        if sebool_state == "enabled":
            sebool = "true"
        if sebool_state == "disabled":
            sebool = "false"

        return sebool_state, sebool
