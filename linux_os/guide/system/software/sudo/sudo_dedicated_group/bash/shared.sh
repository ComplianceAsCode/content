# platform =  multi_platform_rhel

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

{{{ bash_instantiate_variables("var_sudo_dedicated_group") }}}

# Make sure the dedicated group exists
if ! grep "^$var_sudo_dedicated_group" /etc/group; then
    groupadd $var_sudo_dedicated_group
fi

# Assign sudo to the dedicated group
chown :$var_sudo_dedicated_group /usr/bin/sudo
