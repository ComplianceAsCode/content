#!/bin/bash
# platform = multi_platform_ubuntu

sed -i --follow-symlinks '/\bremember=\d+\b/d' /etc/pam.d/common-*
