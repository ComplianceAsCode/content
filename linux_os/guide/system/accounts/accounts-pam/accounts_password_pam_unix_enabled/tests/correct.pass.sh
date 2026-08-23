#!/bin/bash
# platform = multi_platform_rhel

# Ensure pam_unix.so is present in all sections of both PAM files
{{{ bash_ensure_pam_module_line_unix_enable(["password-auth", "system-auth"], ["auth", "account", "password", "session"]) }}}
