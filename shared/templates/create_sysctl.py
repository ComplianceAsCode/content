import re

from template_common import FilesGenerator, UnknownTargetError, CSVLineError


ONE_FILE_OVAL_OUTPUT = False


class SysctlGenerator(FilesGenerator):
    def is_ipv6_id(self, var_id):
        return var_id.find("ipv6") >= 0

    def get_files_for_id(self, var_id):

        if self.is_ipv6_id(var_id):
            template_type = 'I'  # I = ipv6
        else:
            template_type = 'P'  # P = plain

        if ONE_FILE_OVAL_OUTPUT:
            ret = {"": template_type + "SR"}
        else:
            ret = {
                "static_": "S",
                "runtime_": "R",
                "": template_type,
            }
        return ret

    def generate(self, target, serviceinfo):

        # get the items out of the list
        # items can be in format
        # <sysctl_parameter_name, value> or
        # <sysctl_parameter_name, value, type>
        if len(serviceinfo) == 2:
            sysctl_var, sysctl_val = serviceinfo
            # Default data type for sysctl is int
            data_type = "int"
        elif len(serviceinfo) == 3:
            sysctl_var, sysctl_val, data_type = serviceinfo
        else:
            raise CSVLineError()

        # convert variable name to a format suitable for 'id' tags
        sysctl_var_id = re.sub(r'[-\.]', '_', sysctl_var)

        if target == "bash":
            # if the sysctl value is not present, use the variable template
            if not sysctl_val.strip():
                sysctl_val = ""

            self.file_from_template(
                "./template_BASH_sysctl",
                {
                    "SYSCTLID":  sysctl_var_id,
                    "SYSCTLVAR": sysctl_var,
                    "SYSCTLVAL": sysctl_val
                },
                "./bash/sysctl_{0}.sh", sysctl_var_id
            )

        elif target == "ansible":
            # if the sysctl value is not present, use the variable template
            if not sysctl_val.strip():
                sysctl_val = ""

            self.file_from_template(
                "./template_ANSIBLE_sysctl",
                {
                    "SYSCTLID":  sysctl_var_id,
                    "SYSCTLVAR": sysctl_var,
                    "SYSCTLVAL": sysctl_val
                },
                "./ansible/sysctl_{0}.yml", sysctl_var_id
            )

        elif target == "oval":
            if not sysctl_val.strip():
                sysctl_val = ""

            # open the template files and perform the conversions
            for stem, ttype in self.get_files_for_id(sysctl_var_id).items():
                self.file_from_template(
                    "template_OVAL_sysctl",
                    {
                        "FLAGS": ttype,
                        "SYSCTLID":  sysctl_var_id,
                        "SYSCTLVAR": sysctl_var,
                        "SYSCTLVAL": sysctl_val,
                        "DATATYPE": data_type,
                    },
                    "./oval/sysctl_{0}{1}.xml", stem, sysctl_var_id
                )

        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: " +
               "sysctlvariable,sysctlvalue[,<datatype>]")
