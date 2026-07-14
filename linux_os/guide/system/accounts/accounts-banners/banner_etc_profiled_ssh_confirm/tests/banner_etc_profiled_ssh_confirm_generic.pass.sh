#!/bin/bash
# platform = multi_platform_all
# variables = var_ssh_confirm_text=generic_default
{{% set var_ssh_confirm_text='#!/bin/bash
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    while true; do
        read -p " 
This system is accessible only to authorized users.
By accessing this system, you agree to comply with the applicable acceptable use policy and security requirements.
Unauthorized access, use, or modification of this system is prohibited and may be subject to disciplinary action or legal penalties.
All activity on this system may be monitored, recorded, and audited in accordance with applicable policies.
Do you agree? [y/N] " yn
        case $yn in
            [Yy]* ) break ;;
            [Nn]* ) exit 1 ;;
        esac
    done
fi
' %}}
echo '{{{ var_ssh_confirm_text }}}' | fold -sw 80 >/etc/profile.d/ssh_confirm.sh
