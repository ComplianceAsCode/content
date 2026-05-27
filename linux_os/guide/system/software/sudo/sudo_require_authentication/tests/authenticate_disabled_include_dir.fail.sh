#!/bin/bash
# platform = SUSE Linux Enterprise 16
# packages = sudo

touch /etc/sudoers
echo "Defaults !authenticate" > /etc/sudoers.d/sudoers
