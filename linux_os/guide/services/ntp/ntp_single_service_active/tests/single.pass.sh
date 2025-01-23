#!/bin/bash
# remediation = none

{{{ bash_package_install("chrony") }}}
{{{ bash_package_install("systemd-timesyncd") }}}

systemctl stop chrony.service
systemctl stop systemd-timesyncd.service
systemctl disable chrony.service
systemctl disable systemd-timesyncd.service

systemctl start chrony.service
systemctl enable chrony.service
