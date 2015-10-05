# platform = multi_platform_rhel, multi_platform_fedora

SSHD_CONFIG='/etc/ssh/sshd_config'

# Obtain line number of first uncommented case-insensitive occurrence of Match
# block directive (possibly prefixed with whitespace) present in $SSHD_CONFIG
FIRST_MATCH_BLOCK=$(sed -n '/^[[:space:]]*Match[^\n]*/I{=;q}' $SSHD_CONFIG)

# Obtain line number of first uncommented case-insensitive occurence of
# PermitEmptyPasswords directive (possibly prefixed with whitespace) present in
# $SSHD_CONFIG
FIRST_PERMIT_EMPTY_PASSWORDS=$(sed -n '/^[[:space:]]*PermitEmptyPasswords[^\n]*/I{=;q}' $SSHD_CONFIG)

# Case: Match block directive not present in $SSHD_CONFIG
if [ -z "$FIRST_MATCH_BLOCK" ]
then

    # Case: PermitEmptyPasswords directive not present in $SSHD_CONFIG yet
    if [ -z "$FIRST_PERMIT_EMPTY_PASSWORDS" ]
    then
        # Append 'PermitEmptyPasswords no' at the end of $SSHD_CONFIG
        echo -e "\nPermitEmptyPasswords no" >> $SSHD_CONFIG

    # Case: PermitEmptyPasswords directive present in $SSHD_CONFIG already
    else
        # Replace first uncommented case-insensitive occurrence
        # of PermitEmptyPasswords directive
        sed -i "$FIRST_PERMIT_EMPTY_PASSWORDS s/^[[:space:]]*PermitEmptyPasswords.*$/PermitEmptyPasswords no/I" $SSHD_CONFIG
    fi

# Case: Match block directive present in $SSHD_CONFIG
else

    # Case: PermitEmptyPasswords directive not present in $SSHD_CONFIG yet
    if [ -z "$FIRST_PERMIT_EMPTY_PASSWORDS" ]
    then
        # Prepend 'PermitEmptyPasswords no' before first uncommented
        # case-insensitive occurrence of Match block directive
        sed -i "$FIRST_MATCH_BLOCK s/^\([[:space:]]*Match[^\n]*\)/PermitEmptyPasswords no\n\1/I" $SSHD_CONFIG

    # Case: PermitEmptyPasswords directive present in $SSHD_CONFIG and placed
    #       before first Match block directive
    elif [ "$FIRST_PERMIT_EMPTY_PASSWORDS" -lt "$FIRST_MATCH_BLOCK" ]
    then
        # Replace first uncommented case-insensitive occurrence
        # of PermitEmptyPasswords directive
        sed -i "$FIRST_PERMIT_EMPTY_PASSWORDS s/^[[:space:]]*PermitEmptyPasswords.*$/PermitEmptyPasswords no/I" $SSHD_CONFIG

    # Case: PermitEmptyPasswords directive present in $SSHD_CONFIG and placed
    # after first Match block directive
    else
         # Prepend 'PermitEmptyPasswords no' before first uncommented
         # case-insensitive occurrence of Match block directive
         sed -i "$FIRST_MATCH_BLOCK s/^\([[:space:]]*Match[^\n]*\)/PermitEmptyPasswords no\n\1/I" $SSHD_CONFIG
    fi
fi
