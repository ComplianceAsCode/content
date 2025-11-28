#!/bin/bash
# platform = multi_platform_rhel
{{{ bash_ensure_pam_module_option("/etc/pam.d/system-auth", "password", "required", "pam_pwhistory.so", "remember") }}}
{{{ bash_ensure_pam_module_option("/etc/pam.d/password-auth", "password", "required", "pam_pwhistory.so", "remember") }}}
