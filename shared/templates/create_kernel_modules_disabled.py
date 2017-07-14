#
# create_kernel_modules_disabled.py
#   automatically generate checks for disabled kernel modules

from template_common import FilesGenerator, UnknownTargetError


class KernelModulesDisabledGenerator(FilesGenerator):
    def generate(self, target, kerninfo):
        # get the items out of the list
        kernmod = kerninfo[0]

        if target == "bash":
            self.file_from_template(
                "./template_BASH_kernel_module_disabled",
                {
                   "%KERNMODULE%": kernmod
                },
                "./bash/kernel_module_{0}_disabled.sh", kernmod
            )

        elif target == "oval":
            self.file_from_template(
                "./template_OVAL_kernel_module_disabled",
                {
                    "%KERNMODULE%": kernmod
                },
                "./oval/kernel_module_{0}_disabled.xml", kernmod
            )

        elif target == "ansible":
            self.file_from_template(
                "./template_ANSIBLE_kernel_module_disabled",
                {
                   "%KERNMODULE%": kernmod
                },
                "./ansible/kernel_module_{0}_disabled.yml", kernmod
            )

        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return (
            "CSV file should contains lines of the format: kernmod"
        )
