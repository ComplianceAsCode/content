#!/bin/bash
# platform = multi_platform_ol

sed -i '/pam_succeed_if/d' /etc/pam.d/sudo
