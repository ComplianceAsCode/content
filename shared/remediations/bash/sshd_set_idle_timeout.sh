# platform = multi_platform_rhel, multi_platform_fedora
. /usr/share/scap-security-guide/remediation_functions
declare sshd_idle_timeout_value
populate sshd_idle_timeout_value

SSHD_CONFIG='/etc/ssh/sshd_config'

# Obtain line number of first uncommented case-insensitive occurrence of Match
# block directive (possibly prefixed with whitespace) present in $SSHD_CONFIG
FIRST_MATCH_BLOCK=$(sed -n '/^[[:space:]]*Match[^\n]*/I{=;q}' $SSHD_CONFIG)

# Obtain line number of first uncommented case-insensitive occurence of
# ClientAliveInterval directive (possibly prefixed with whitespace) present in
# $SSHD_CONFIG
FIRST_CLIENT_ALIVE_INTERVAL=$(sed -n '/^[[:space:]]*ClientAliveInterval[^\n]*/I{=;q}' $SSHD_CONFIG)

# Case: Match block directive not present in $SSHD_CONFIG
if [ -z "$FIRST_MATCH_BLOCK" ]
then

    # Case: ClientAliveInterval directive not present in $SSHD_CONFIG yet
    if [ -z "$FIRST_CLIENT_ALIVE_INTERVAL" ]
    then
        # Append 'ClientAliveInterval $sshd_idle_timeout_value' at the end of $SSHD_CONFIG
        echo -e "\nClientAliveInterval $sshd_idle_timeout_value" >> $SSHD_CONFIG

    # Case: ClientAliveInterval directive present in $SSHD_CONFIG already
    else
        # Replace first uncommented case-insensitive occurrence
        # of ClientAliveInterval directive
        sed -i "$FIRST_CLIENT_ALIVE_INTERVAL s/^[[:space:]]*ClientAliveInterval.*$/ClientAliveInterval $sshd_idle_timeout_value/I" $SSHD_CONFIG
    fi

# Case: Match block directive present in $SSHD_CONFIG
else

    # Case: ClientAliveInterval directive not present in $SSHD_CONFIG yet
    if [ -z "$FIRST_CLIENT_ALIVE_INTERVAL" ]
    then
        # Prepend 'ClientAliveInterval $sshd_idle_timeout_value' before first uncommented
        # case-insensitive occurrence of Match block directive
        sed -i "$FIRST_MATCH_BLOCK s/^\([[:space:]]*Match[^\n]*\)/ClientAliveInterval $sshd_idle_timeout_value\n\1/I" $SSHD_CONFIG

    # Case: ClientAliveInterval directive present in $SSHD_CONFIG and placed
    #       before first Match block directive
    elif [ "$FIRST_CLIENT_ALIVE_INTERVAL" -lt "$FIRST_MATCH_BLOCK" ]
    then
        # Replace first uncommented case-insensitive occurrence
        # of ClientAliveInterval directive
        sed -i "$FIRST_CLIENT_ALIVE_INTERVAL s/^[[:space:]]*ClientAliveInterval.*$/ClientAliveInterval $sshd_idle_timeout_value/I" $SSHD_CONFIG

    # Case: ClientAliveInterval directive present in $SSHD_CONFIG and placed
    # after first Match block directive
    else
         # Prepend 'ClientAliveInterval $sshd_idle_timeout_value' before first uncommented
         # case-insensitive occurrence of Match block directive
         sed -i "$FIRST_MATCH_BLOCK s/^\([[:space:]]*Match[^\n]*\)/ClientAliveInterval $sshd_idle_timeout_value\n\1/I" $SSHD_CONFIG
    fi
fi
