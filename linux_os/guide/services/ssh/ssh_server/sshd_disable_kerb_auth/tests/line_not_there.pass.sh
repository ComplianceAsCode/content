#!/bin/bash
#

sed -i "/^KerberosAuthentication.*/d" /etc/ssh/sshd_config
