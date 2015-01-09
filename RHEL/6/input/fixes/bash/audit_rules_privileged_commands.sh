
readonly AUDIT_RULES='/etc/audit/audit.rules'

# Obtain the list of SUID/SGID binaries on the particular system into PRIVILEGED_BINARIES array
PRIVILEGED_BINARIES=($(find / -xdev -type f -perm -4000 -o -type f -perm -2000 2>/dev/null))

# For each found binary from that list...
for SBINARY in ${PRIVILEGED_BINARIES[@]}
do

    # Define base rule pattern for this binary to search existing audit.rules' content for match
    BASE_RULE="-a always,exit -F path=${SBINARY} -F perm=.* -F auid>=500 -F auid!=4294967295 -k privileged"

    # Define expected rule form for this binary
    EXPECTED_RULE="-a always,exit -F path=${SBINARY} -F perm=x -F auid>=500 -F auid!=4294967295 -k privileged"

    # Require execute access type to be set for existing audit rule
    EXEC_ACCESS='x'

    # Search existing audit.rules content for presence of rule pattern for this binary
    if grep -q -- "$BASE_RULE" $AUDIT_RULES
    then

        # Current /etc/audit/audit.rules already contains rule for this binary =>
        # Load it's exact form into CONCRETE_RULE variable for further processing
        CONCRETE_RULE=$(cat $AUDIT_RULES | grep -- "$BASE_RULE")

        # Separate that rule into three sections using hash '#'
        # sign as a delimiter around rule's permission section borders
        CONCRETE_RULE=$(echo $CONCRETE_RULE | sed -n "s/\(.*\)\+\(-F perm=[rwax]\+\)\+/\1#\2#/p")

        # Split that rule into head, perm, and tail sections using hash '#' delimiter
        IFS=$'#' read RULE_HEAD RULE_PERM RULE_TAIL <<<  "$CONCRETE_RULE"

        # Extract already present exact access type [r|w|x|a] from rule's permission section
        ACCESS_TYPE=${RULE_PERM//-F perm=/}

        # Verify current permission access type(s) for rule contain 'x' (execute) permission
        if ! grep -q "$EXEC_ACCESS" <<< "$ACCESS_TYPE"
        then

            # If not, append the 'x' (execute) permission to the existing access type bits
            ACCESS_TYPE="$ACCESS_TYPE$EXEC_ACCESS"
            # Reconstruct the permissions section for the rule
            NEW_RULE_PERM="-F perm=$ACCESS_TYPE"
            # Update existing rule in /etc/audit/audit.rules with the new permission section
            sed -i "s#${RULE_HEAD}\(.*\)${RULE_TAIL}#${RULE_HEAD}${NEW_RULE_PERM}${RULE_TAIL}#" $AUDIT_RULES

        fi

    else

        # Current /etc/audit/audit.rules content doesn't contain expected rule for this
        # SUID/SGID binary yet => append it
        echo $EXPECTED_RULE >> $AUDIT_RULES
    fi

done
