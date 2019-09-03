#!/bin/bash
#
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8
# profiles = xccdf_org.ssgproject.content_profile_ospp, xccdf_org.ssgproject.content_profile_standard

SSH_CONF="/etc/sysconfig/sshd"

rm -f $SSH_CONF
