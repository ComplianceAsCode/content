#
# create_ocp_service_runtime_config.py
#   automatically generate checks for ocp process runtime configurations

import sys
import re

from template_common import FilesGenerator, UnknownTargetError


class OCPServiceRuntimeConfigGenerator(FilesGenerator):
    def generate(self, target, ocp_process_info):
        process_cmd, process_cmd_option, process_cmd_val = ocp_process_info[0:3]

        # convert variable name to a format suitable for 'id' tags
        ocp_proc_id = re.sub(r'[-._]', '_', process_cmd_option.strip("--="))
        process_cmd_option = process_cmd_option.strip("=")

        if len(ocp_process_info) == 4:
            ocp_proc_id = ocp_process_info[3]

        if target == "oval":
            self.file_from_template(
                "./template_OVAL_ocp_service_runtime_config",
                {
                    "OCPCMDOPTIONID": ocp_proc_id,
                    "OCPPROCESS": process_cmd,
                    "OCPCMDOPTION": process_cmd_option,
                    "OCPCMDVAL": process_cmd_val
                },
                "./oval/ocp_service_runtime_config_{0}.xml", ocp_proc_id)

#        elif target == "bash":
#            self.file_from_template(
#                "./template_BASH_ocp_service_runtime_config",
#                {
#                    "OCPPROCESS": process_cmd,
#                    "OCPCMDOPTION": process_cmd_option,
#                    "OCPCMDVAL": process_cmd_val
#                    },
#                "./bash/ocp_service_runtime_config_{0}.sh", ocp_proc_id)
#
#        elif target == "ansible":
#            self.file_from_template(
#                "./template_ANSIBLE_ocp_service_runtime_config",
#                {
#                    "OCPPROCESS": process_cmd,
#                    "OCPCMDOPTION": process_cmd_option,
#                    "OCPCMDVAL": process_cmd_val
#                },
#                "./ansible/ocp_service_runtime_config_{0}.yml", ocp_proc_id)

        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: " +
               "process_cmd,process_cmd_option,process_cmd_val")
