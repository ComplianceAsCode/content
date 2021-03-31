#!/bin/bash
# platform = Red Hat Enterprise Linux 8
# packages = dhcp-server

systemctl stop dhcpd
systemctl disable dhcpd
systemctl mask dhcpd
