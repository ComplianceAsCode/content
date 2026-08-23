#!/bin/bash
#

rpm --setperms openssh-server
chmod 0644 /etc/ssh/sshd_config
