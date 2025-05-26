#!/bin/bash
# platform = multi_platform_ol,multi_platform_sle,multi_platform_almalinux

sed -i '/pam_succeed_if/d' /etc/pam.d/sudo
