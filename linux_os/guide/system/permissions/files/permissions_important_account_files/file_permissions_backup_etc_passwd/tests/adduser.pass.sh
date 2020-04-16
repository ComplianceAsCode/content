#!/bin/bash
USER=ssgttuser

# set wrong permissions
chmod 600 /etc/passwd-

# useradd will copy the backup file with permissions from the
# actual /etc/passwd file containing correct permissions
useradd ${USER}

