# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low
if [ -e "/etc/ssh/sshd_config" ] ; then
    LC_ALL=C sed -i "/^\s*UsePrivilegeSeparation\s\+/Id" "/etc/ssh/sshd_config"
else
    touch "/etc/ssh/sshd_config"
fi
# Include source function library.
. /usr/share/scap-security-guide/remediation_functions
populate var_sshd_priv_separation

cp "/etc/ssh/sshd_config" "/etc/ssh/sshd_config.bak"
# Insert before the line matching the regex '^Match'.
local line_number="$(LC_ALL=C grep -n "^Match" "/etc/ssh/sshd_config.bak" | LC_ALL=C sed 's/:.*//g')"
if [ -z "$line_number" ]; then
    # There was no match of '^Match', insert at
    # the end of the file.
    printf '%s\n' "UsePrivilegeSeparation $var_sshd_priv_separation" >> "/etc/ssh/sshd_config"
else
    head -n "$(( line_number - 1 ))" "/etc/ssh/sshd_config.bak" > "/etc/ssh/sshd_config"
    printf '%s\n' "UsePrivilegeSeparation $var_sshd_priv_separation" >> "/etc/ssh/sshd_config"
    tail -n "+$(( line_number ))" "/etc/ssh/sshd_config.bak" >> "/etc/ssh/sshd_config"
fi
# Clean up after ourselves.
rm "/etc/ssh/sshd_config.bak"
