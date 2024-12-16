#!/bin/bash
# platform = multi_platform_ubuntu

sed -i 's/\(^.*pam_pwquality\.so.*\)/# \1/' /etc/pam.d/common-password
