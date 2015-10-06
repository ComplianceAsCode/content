# platform = multi_platform_rhel, multi_platform_fedora

SSHD_CONFIG='/etc/ssh/sshd_config'

# Obtain line number of first uncommented case-insensitive occurrence of Match
# block directive (possibly prefixed with whitespace) present in $SSHD_CONFIG
FIRST_MATCH_BLOCK=$(sed -n '/^[[:space:]]*Match[^\n]*/I{=;q}' $SSHD_CONFIG)

# Obtain line number of first uncommented case-insensitive occurence of
# PermitRootLogin directive (possibly prefixed with whitespace) present in
# $SSHD_CONFIG
FIRST_PERMIT_ROOT_LOGIN=$(sed -n '/^[[:space:]]*PermitRootLogin[^\n]*/I{=;q}' $SSHD_CONFIG)

# Case: Match block directive not present in $SSHD_CONFIG
if [ -z "$FIRST_MATCH_BLOCK" ]
then

    # Case: PermitRootLogin directive not present in $SSHD_CONFIG yet
    if [ -z "$FIRST_PERMIT_ROOT_LOGIN" ]
    then
        # Append 'PermitRootLogin no' at the end of $SSHD_CONFIG
        echo -e "\nPermitRootLogin no" >> $SSHD_CONFIG

    # Case: PermitRootLogin directive present in $SSHD_CONFIG already
    else
        # Replace first uncommented case-insensitive occurrence
        # of PermitRootLogin directive
        sed -i "$FIRST_PERMIT_ROOT_LOGIN s/^[[:space:]]*PermitRootLogin.*$/PermitRootLogin no/I" $SSHD_CONFIG
    fi

# Case: Match block directive present in $SSHD_CONFIG
else

    # Case: PermitRootLogin directive not present in $SSHD_CONFIG yet
    if [ -z "$FIRST_PERMIT_ROOT_LOGIN" ]
    then
        # Prepend 'PermitRootLogin no' before first uncommented
        # case-insensitive occurrence of Match block directive
        sed -i "$FIRST_MATCH_BLOCK s/^\([[:space:]]*Match[^\n]*\)/PermitRootLogin no\n\1/I" $SSHD_CONFIG

    # Case: PermitRootLogin directive present in $SSHD_CONFIG and placed
    #       before first Match block directive
    elif [ "$FIRST_PERMIT_ROOT_LOGIN" -lt "$FIRST_MATCH_BLOCK" ]
    then
        # Replace first uncommented case-insensitive occurrence
        # of PermitRootLogin directive
        sed -i "$FIRST_PERMIT_ROOT_LOGIN s/^[[:space:]]*PermitRootLogin.*$/PermitRootLogin no/I" $SSHD_CONFIG

    # Case: PermitRootLogin directive present in $SSHD_CONFIG and placed
    # after first Match block directive
    else
         # Prepend 'PermitRootLogin no' before first uncommented
         # case-insensitive occurrence of Match block directive
         sed -i "$FIRST_MATCH_BLOCK s/^\([[:space:]]*Match[^\n]*\)/PermitRootLogin no\n\1/I" $SSHD_CONFIG
    fi
fi
