#!/bin/bash
# platform = Red Hat Enterprise Linux 7,SUSE Linux Enterprise 15
# packages = dhcp

systemctl stop dhcpd
systemctl disable dhcpd
systemctl mask dhcpd
