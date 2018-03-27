#
# create_mounts.py
#        generate template-based checks for partitions and partition
#        mount rights

import re

from template_common import FilesGenerator, UnknownTargetError


class MountOptionTarget(object):
    def __init__(self, generator, output_format_string):
        self.output_format_string = output_format_string
        self.generator = generator

    def process(self, mount_point, mount_option, point_id, template_file):
        raise NotImplementedError("You are supposed to use a derived class.")


class RemediationTarget(MountOptionTarget):
    def process(self, mount_point, mount_option, point_id, template_file, stem=""):
        if len(stem) == 0:
            stem = point_id + '_' + mount_option
        self.generator.file_from_template(
            template_file,
            {
                "%MOUNTPOINT%":  mount_point,
                "%MOUNTOPTION%": re.sub(' ', ',', mount_option),
            },
            self.output_format_string,
            stem
        )


class OvalTarget(MountOptionTarget):
    def __init__(self, generator):
        super(OvalTarget, self).__init__(
            generator, "./oval/mount_option{0}.xml")

    def process(self, mount_point, mount_option, point_id, template_file, stem=""):
        if len(stem) == 0:
            stem = point_id + '_' + mount_option
        self.generator.file_from_template(
            template_file,
            {
                "%MOUNTPOINT%":  mount_point,
                "%MOUNTOPTION%": mount_option,
                "%POINTID%":     point_id,
            },
            self.output_format_string,
            stem
        )


class MountOptionsGenerator(FilesGenerator):
    def __init__(self):
        self.targets = {}
        self.targets["bash"] = RemediationTarget(
            self, "./bash/mount_option{0}.sh")
        self.targets["ansible"] = RemediationTarget(
            self, "./ansible/mount_option{0}.yml")
        self.targets["anaconda"] = RemediationTarget(
            self, "./anaconda/mount_option{0}.anaconda")
        self.targets["oval"] = OvalTarget(self)
        super(MountOptionsGenerator, self).__init__()

    def generate(self, target, path_info):
        mount_point, mount_option = path_info
        if mount_point:

            processing_entity = self.targets.get(target)
            if processing_entity is None:
                raise UnknownTargetError(target)

            point_id = re.sub('[-\./]', '_', mount_point)

            uppercase_target_name = target.upper()
            template_file = "./template_{0}_mount_option".format(uppercase_target_name)
            stem = ""
            if mount_point.startswith("var_"):
                # var_removable_partition -> removable_partitions
                point_id = re.sub(r"^var_(.*)", r"\1s", mount_point)
                template_file = "{0}_var".format(template_file)
                stem = "_{0}_{1}".format(mount_option, point_id)

            processing_entity.process(mount_point, mount_option, point_id, template_file, stem)

    def csv_format(self):
        return("CSV should contains lines of the format: "
               "mount_point,mount_option,[mount_option]+")
