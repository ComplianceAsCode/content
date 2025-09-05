#!/bin/bash
# packages = sudo,authselect
# platform = multi_platform_rhel,Fedora
# profiles = xccdf_org.ssgproject.content_profile_cis
# remediation = none
# variables = var_password_pam_remember=5,var_password_pam_remember_control_flag=requisite

echo "RekeyLimit 1000" >> "/etc/ssh/sshd_config"
