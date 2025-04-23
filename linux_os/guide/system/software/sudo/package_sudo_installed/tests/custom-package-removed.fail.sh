#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora

# Package libselinux cannot be uninstalled normally
# as it would cause removal of sudo package which is
# protected and package manager returns error in such
# case. If the package would be removed forcefully it
# would make the system unusable. Therefore, we will
# remove the package only from RPM database
rpm -e --nodeps --justdb sudo
