#!/bin/bash
#
USER=ssgttuser

useradd ${USER}
touch /etc/ssh/sshd_config
chown ${USER} /etc/ssh/sshd_config
