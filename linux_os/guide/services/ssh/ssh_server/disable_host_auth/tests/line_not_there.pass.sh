#!/bin/bash
#

sed -i "/^HostbasedAuthentication.*/d" /etc/ssh/sshd_config
