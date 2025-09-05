#!/usr/bin/python2

#
# create_grub2_bootloader_argument.py
#        generate template-based checks for unsuccessful file modifications detailed


from template_common import FilesGenerator, UnknownTargetError

import re

class GRUB2BootloaderArgumentGenerator(FilesGenerator):
    def generate(self, target, args):
        arg_name, arg_value = args[0:2]
        arg_name_value = arg_name + '=' + arg_value

        if target == "bash":
            self.file_from_template(
                "./template_BASH_grub2_bootloader_argument",
                {
                    "ARG_NAME": arg_name,
                    "ARG_NAME_VALUE": arg_name_value
                },
                "./bash/grub2_{0}_argument.sh", arg_name
            )
        elif target == "oval":
            self.file_from_template(
                "./template_OVAL_grub2_bootloader_argument",
                {
                    "ARG_NAME": arg_name,
                    "ARG_NAME_VALUE": arg_name_value
                },
                "./oval/grub2_{0}_argument.xml", arg_name
            )
        elif target == "ansible":
            self.file_from_template(
                "./template_ANSIBLE_grub2_bootloader_argument",
                {
                    "ARG_NAME": arg_name,
                    "ARG_NAME_VALUE": arg_name_value
                },
                "./ansible/grub2_{0}_argument.yml", arg_name
            )
        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: " +
               "SYSCALL")
