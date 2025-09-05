import re

from template_common import FilesGenerator, UnknownTargetError, CSVLineError


class SysctlGenerator(FilesGenerator):
    def is_ipv6_id(self, var_id):
        return var_id.find("ipv6") >= 0

    def get_files_var_for_id(self, var_id):

        if self.is_ipv6_id(var_id):
            template_name = 'template_OVAL_sysctl_ipv6'
        else:
            template_name = 'template_OVAL_sysctl'

        return {
            'template_OVAL_sysctl_static_var': 'sysctl_static_',
            'template_OVAL_sysctl_runtime_var': 'sysctl_runtime_',
            template_name: 'sysctl_'
        }

    def get_files_for_id(self, var_id):
        if self.is_ipv6_id(var_id):
            template_name = 'template_OVAL_sysctl_ipv6'
        else:
            template_name = 'template_OVAL_sysctl'

        return {
            'template_OVAL_sysctl_static': 'sysctl_static_',
            'template_OVAL_sysctl_runtime': 'sysctl_runtime_',
            template_name: 'sysctl_'
        }

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
        sysctl_var_id = re.sub('[-\.]', '_', sysctl_var)

        if target == "bash":
            # if the sysctl value is not present, use the variable template
            if not sysctl_val.strip():
                # open the template and perform the conversions
                self.file_from_template(
                    "template_BASH_sysctl_var",
                    {
                        "SYSCTLID":  sysctl_var_id,
                        "SYSCTLVAR": sysctl_var
                    },
                    "./bash/sysctl_{0}.sh", sysctl_var_id
                )
            else:
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
                # open the template and perform the conversions
                self.file_from_template(
                    "template_ANSIBLE_sysctl_var",
                    {
                        "SYSCTLID":  sysctl_var_id,
                        "SYSCTLVAR": sysctl_var
                    },
                    "./ansible/sysctl_{0}.yml", sysctl_var_id
                )
            else:
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
            # if the sysctl value is not present, use the variable template
            if not sysctl_val.strip():

                # open the template files and perform the conversions
                for sysctlfile, prefix in self.get_files_var_for_id(sysctl_var_id).items():
                    self.file_from_template(
                        sysctlfile,
                        {
                            "SYSCTLID":  sysctl_var_id,
                            "SYSCTLVAR": sysctl_var,
                            "DATATYPE": data_type,
                        },
                        "./oval/{0}.xml", prefix + sysctl_var_id
                    )

            else:
                # open the template files and perform the conversions
                for sysctlfile, prefix in self.get_files_for_id(sysctl_var_id).items():
                    self.file_from_template(
                        sysctlfile,
                        {
                            "SYSCTLID":  sysctl_var_id,
                            "SYSCTLVAR": sysctl_var,
                            "SYSCTLVAL": sysctl_val,
                            "DATATYPE": data_type,
                        },
                        "./oval/{0}.xml", prefix + sysctl_var_id
                    )

        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: " +
               "sysctlvariable,sysctlvalue[,<datatype>]")
