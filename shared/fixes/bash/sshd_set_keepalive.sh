# platform = multi_platform_rhel, multi_platform_fedora

SSHD_CONFIG='/etc/ssh/sshd_config'

# Obtain line number of first uncommented case-insensitive occurrence of Match
# block directive (possibly prefixed with whitespace) present in $SSHD_CONFIG
FIRST_MATCH_BLOCK=$(sed -n '/^[[:space:]]*Match[^\n]*/I{=;q}' $SSHD_CONFIG)

# Obtain line number of first uncommented case-insensitive occurence of
# ClientAliveCountMax directive (possibly prefixed with whitespace) present in
# $SSHD_CONFIG
FIRST_CLIENT_ALIVE_COUNT_MAX=$(sed -n '/^[[:space:]]*ClientAliveCountMax[^\n]*/I{=;q}' $SSHD_CONFIG)

# Case: Match block directive not present in $SSHD_CONFIG
if [ -z "$FIRST_MATCH_BLOCK" ]
then

    # Case: ClientAliveCountMax directive not present in $SSHD_CONFIG yet
    if [ -z "$FIRST_CLIENT_ALIVE_COUNT_MAX" ]
    then
        # Append 'ClientAliveCountMax 0' at the end of $SSHD_CONFIG
        echo -e "\nClientAliveCountMax 0" >> $SSHD_CONFIG

    # Case: ClientAliveCountMax directive present in $SSHD_CONFIG already
    else
        # Replace first uncommented case-insensitive occurrence
        # of ClientAliveCountMax directive
        sed -i "$FIRST_CLIENT_ALIVE_COUNT_MAX s/^[[:space:]]*ClientAliveCountMax.*$/ClientAliveCountMax 0/I" $SSHD_CONFIG
    fi

# Case: Match block directive present in $SSHD_CONFIG
else

    # Case: ClientAliveCountMax directive not present in $SSHD_CONFIG yet
    if [ -z "$FIRST_CLIENT_ALIVE_COUNT_MAX" ]
    then
        # Prepend 'ClientAliveCountMax 0' before first uncommented
        # case-insensitive occurrence of Match block directive
        sed -i "$FIRST_MATCH_BLOCK s/^\([[:space:]]*Match[^\n]*\)/ClientAliveCountMax 0\n\1/I" $SSHD_CONFIG

    # Case: ClientAliveCountMax directive present in $SSHD_CONFIG and placed
    #       before first Match block directive
    elif [ "$FIRST_CLIENT_ALIVE_COUNT_MAX" -lt "$FIRST_MATCH_BLOCK" ]
    then
        # Replace first uncommented case-insensitive occurrence
        # of ClientAliveCountMax directive
        sed -i "$FIRST_CLIENT_ALIVE_COUNT_MAX s/^[[:space:]]*ClientAliveCountMax.*$/ClientAliveCountMax 0/I" $SSHD_CONFIG

    # Case: ClientAliveCountMax directive present in $SSHD_CONFIG and placed
    # after first Match block directive
    else
         # Prepend 'ClientAliveCountMax 0' before first uncommented
         # case-insensitive occurrence of Match block directive
         sed -i "$FIRST_MATCH_BLOCK s/^\([[:space:]]*Match[^\n]*\)/ClientAliveCountMax 0\n\1/I" $SSHD_CONFIG
    fi
fi
