#!/bin/bash
#
USER=ssgttuser

useradd ${USER}
chown ${USER} /etc/gshadow
