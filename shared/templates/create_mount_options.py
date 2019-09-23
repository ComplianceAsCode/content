#
# create_mounts.py
#        generate template-based checks for partitions and partition
#        mount rights

from __future__ import print_function

import re
import sys
import os

from template_common import FilesGenerator, UnknownTargetError


OUTPUTS_FORMAT_STRINGS = dict(
    bash="./bash/mount_option_{0}.sh",
    ansible="./ansible/mount_option_{0}.yml",
    anaconda="./anaconda/mount_option_{0}.anaconda",
    oval="./oval/mount_option_{0}.xml",
)


class Skipped(Exception):
    pass


class MountOptionTarget(object):
    TEMPLATE_FILE_BASE = None
    OUTPUT_FORMAT_STRING = None

    def __init__(self, generator, target):
        self.OUTPUT_FORMAT_STRING = OUTPUTS_FORMAT_STRINGS[target]
        self.generator = generator
        self.TEMPLATE_FILE_BASE = self.TEMPLATE_FILE_BASE.format(target=target.upper())
        self.template_file = self.TEMPLATE_FILE_BASE

        self._mount_point = ""
        self._mount_option = ""
        self._point_id = ""
        self._output_id_template = "{point_id}_{mount_option}"
        self._assert_mount_exists = True
        self._output_fname = None

    def process(self, mount_point, mount_option, assert_mount_exists, filesystem, mount_type):
        point_id = re.sub('[-\./]', '_', mount_point).lstrip("_")

        try:
            self._translate_input_values(mount_point, mount_option, point_id)
        except Skipped as exc:
            # This would spam the user too many times during build.
            # print("Note: {0} - {1}".format(mount_point, str(exc)), file=sys.stderr)
            return

        self._output_fname = self.OUTPUT_FORMAT_STRING.format(
            self._output_id_template.format(
                point_id=self._point_id, mount_option=self._mount_option)
        )
        self._assert_mount_exists = assert_mount_exists
        self.filesystem = filesystem
        self.mount_type = mount_type
        self._process()

    def _process(self):
        raise NotImplementedError("You are supposed to use a derived class.")

    def _translate_input_values(self, mount_point, mount_option, point_id):
        self._mount_point = mount_point
        self._point_id = point_id
        self._mount_option = mount_option


class RemediationTarget(MountOptionTarget):
    TEMPLATE_FILE_BASE = "./template_{target}_mount_option"

    def _process(self):
        mount_has_to_exist = "yes" if self._assert_mount_exists else "no"
        self.generator.file_from_template(
            self.template_file,
            {
                "MOUNT_HAS_TO_EXIST": mount_has_to_exist,
                "MOUNTPOINT": self._mount_point,
                "MOUNTOPTION": re.sub(' ', ',', self._mount_option),
                "FILESYSTEM": self.filesystem,
                "TYPE": self.mount_type,
            },
            self._output_fname,
            ""
        )

    def _translate_input_values(self, mount_point, mount_option, point_id):
        super(RemediationTarget, self)._translate_input_values(mount_point, mount_option, point_id)
        if mount_point.startswith("var_"):
            self._point_id = re.sub(r"^var_(.*)", r"\1s", mount_point)
            self.template_file = "{0}_removable_partitions".format(self.TEMPLATE_FILE_BASE)
            self._output_id_template = "{mount_option}_{point_id}"
        elif not mount_point.startswith("/"):  # relates to rules specified by descriptive name (e.g. remote_filesystems)
            self.template_file = "{0}_{1}".format(self.TEMPLATE_FILE_BASE, self._point_id)

            template_path = os.path.join(self.generator.product_input_dir, self.template_file)
            if not os.path.isfile(template_path):
                raise Skipped(
                    "Template file {0} doesn't exist.".format(self.template_file)
                )


class OvalTarget(MountOptionTarget):
    TEMPLATE_FILE_BASE = "./template_OVAL_mount_option"

    def __init__(self, generator):
        super(OvalTarget, self).__init__(
            generator, "oval")

    def _translate_input_values(self, mount_point, mount_option, point_id):
        super(OvalTarget, self)._translate_input_values(mount_point, mount_option, point_id)
        if mount_point.startswith("var_"):
            self._point_id = re.sub(r"^var_(.*)", r"\1s", mount_point)
            self.template_file = "{0}_{1}".format(self.TEMPLATE_FILE_BASE, self._point_id)
            self._output_id_template = "{mount_option}_{point_id}"
        elif not mount_point.startswith("/"):  # no path, but not a variable either
            point_id = re.sub(r"^(.*)", r"\1s", mount_point)
            self.template_file = "{0}_{1}".format(self.TEMPLATE_FILE_BASE, self._point_id)

    def _process(self):
        self.generator.file_from_template(
            self.template_file,
            {
                "MOUNTPOINT":  self._mount_point,
                "MOUNTOPTION": self._mount_option,
                "POINTID":     self._point_id,
            },
            self._output_fname,
            ""
        )


class MountOptionsGenerator(FilesGenerator):
    def __init__(self):
        self.targets = {}
        self.targets["bash"] = RemediationTarget(
            self, "bash")
        self.targets["ansible"] = RemediationTarget(
            self, "ansible")
        self.targets["anaconda"] = RemediationTarget(
            self, "anaconda")
        self.targets["oval"] = OvalTarget(self)
        super(MountOptionsGenerator, self).__init__()

    def generate(self, target, path_info):
        mount_point, mount_option = path_info[:2]
        mount_has_to_exist = True
        filesystem = ""
        mount_type = ""
        if len(path_info) > 2:
            assert len(path_info) == 5
            assert path_info[2] == "create_fstab_entry_if_needed"
            filesystem = path_info[3]
            mount_type = path_info[4]
            mount_has_to_exist = False

        assert mount_point

        processing_entity = self.targets.get(target)
        if processing_entity is None:
            raise UnknownTargetError(target)

        processing_entity.process(mount_point, mount_option, mount_has_to_exist, filesystem, mount_type)

    def csv_format(self):
        return("CSV should contains lines of the format: "
               "<mount_point>,<mount_option>[,create_fstab_entry_if_needed,<filesystem>,<type>])")
