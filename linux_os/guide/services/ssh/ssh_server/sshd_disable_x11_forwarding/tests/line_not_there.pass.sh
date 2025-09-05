#!/bin/bash
#

sed -i "/^X11Forwarding.*/d" /etc/ssh/sshd_config
