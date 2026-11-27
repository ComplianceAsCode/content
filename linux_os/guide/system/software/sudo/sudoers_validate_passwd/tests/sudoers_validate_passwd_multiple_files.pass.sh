#!/bin/bash
# platform = SUSE Linux Enterprise 15,multi_platform_almalinux,multi_platform_fedora,multi_platform_ol,multi_platform_opensuse,multi_platform_rhel,multi_platform_slmicro
# packages = sudo

echo 'Defaults !targetpw' >> /etc/sudoers
echo 'Defaults !rootpw' >> /etc/sudoers.d/00-file1
echo 'Defaults !runaspw' >> /etc/sudoers
