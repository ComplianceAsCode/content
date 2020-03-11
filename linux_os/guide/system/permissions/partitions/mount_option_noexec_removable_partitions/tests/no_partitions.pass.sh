#!/bin/bash

# Regression test for rhbz#1403905
# The rule should pass if there is no removable media entry in /etc/fstab

touch /dev/cdrom
echo "" > /etc/fstab
