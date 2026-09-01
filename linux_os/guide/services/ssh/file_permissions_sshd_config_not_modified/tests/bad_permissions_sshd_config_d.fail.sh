#!/bin/bash
#

rpm --setperms openssh-server
chmod 0755 /etc/ssh/sshd_config.d
