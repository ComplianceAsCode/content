#
# create_package_required_version_installed.py
#   automatically generate checks of the required version for installed packages
#

import sys
from template_common import FilesGenerator, UnknownTargetError
from create_package_installed import PackageInstalledGenerator


class PackageRequiredVersionInstalledGenerator (PackageInstalledGenerator):
    def generate(self, target, package_info):
        try:
            # get the items out of the list
            pkgname, epoch, version, release = package_info

        except ValueError as e:
            print("\tEntry: %s\n" % package_info)
            print("\tError unpacking pkgname, epoch, version and release: " + str(e))
            sys.exit(1)

        if target == "oval":
            self.file_from_template(
                "./template_OVAL_package_required_version_installed",
                {
                    "%PKGNAME%": pkgname,
                    "%EPOCH%":   epoch,
                    "%VERSION%": version,
                    "%RELEASE%": release
                },
                "./oval/package_{0}_required_version_installed.xml", pkgname
            )

        elif target == "bash":
            self.file_from_template(
                "./template_BASH_package_installed",
                {"%PKGNAME%": pkgname},
                "./bash/package_{0}_required_version_installed.sh", pkgname
            )

        elif target == "ansible":
            self.file_from_template(
                "./template_ANSIBLE_package_installed",
                {"%PKGNAME%": pkgname},
                "./ansible/package_{0}_required_version_installed.yml", pkgname
            )

        elif target == "anaconda":
            self.file_from_template(
                "./template_ANACONDA_package_installed",
                {"%PKGNAME%": pkgname},
                "./anaconda/package_{0}_required_version_installed.anaconda", pkgname
            )

        elif target == "puppet":
            self.file_from_template(
                "./template_PUPPET_package_installed",
                {"%PKGNAME%": pkgname},
                "./puppet/package_{0}_required_version_installed.pp", pkgname
            )

        else:
            raise UnknownTargetError(target)

    def csv_format(self):
        return("CSV should contains lines of the format: " +
               "PACKAGE_NAME,EPOCH,VERSION,RELEASE")
