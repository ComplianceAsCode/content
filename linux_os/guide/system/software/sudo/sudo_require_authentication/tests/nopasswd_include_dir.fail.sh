#!/bin/bash
# platform = SUSE Linux Enterprise 16
# packages = sudo

touch /etc/sudoers
echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/sudoers
