#!/bin/bash
# platform = multi_platform_rhel

# Ensure pam_unix.so is present in all sections of both PAM files
for pam_file in /etc/pam.d/system-auth /etc/pam.d/password-auth; do
    {{{ bash_ensure_pam_module_line("$pam_file", "auth", "sufficient", "pam_unix.so") }}}
    {{{ bash_ensure_pam_module_line("$pam_file", "account", "required", "pam_unix.so") }}}
    {{{ bash_ensure_pam_module_line("$pam_file", "password", "sufficient", "pam_unix.so") }}}
    {{{ bash_ensure_pam_module_line("$pam_file", "session", "required", "pam_unix.so") }}}
done
