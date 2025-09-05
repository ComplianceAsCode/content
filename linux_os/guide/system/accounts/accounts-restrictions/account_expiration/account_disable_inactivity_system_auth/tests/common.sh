#!/bin/bash

authselect create-profile testingProfile --base-on minimal

CUSTOM_PAM_FILE="/etc/authselect/custom/testingProfile/system-auth"


if grep -q "pam_lastlog\.so.*" "$CUSTOM_PAM_FILE" ; then
    sed -i --follow-symlinks "/pam_lastlog\.so/d" "$CUSTOM_PAM_FILE"
fi
{{{ bash_ensure_pam_module_line("$CUSTOM_PAM_FILE",
                                "auth",
                                "sufficient",
                                "pam_unix.so") }}}

authselect select --force custom/testingProfile
