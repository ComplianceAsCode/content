
readonly AUDIT_RULES='/etc/audit/audit.rules'

# Obtain the list of SUID/SGID binaries on the particular system into PRIVILEGED_BINARIES array
PRIVILEGED_BINARIES=($(find / -xdev -type f -perm -4000 -o -type f -perm -2000 2>/dev/null))

# Keep list of SUID/SGID binaries that have been already handled within some previous iteration
declare -a SBINARIES_TO_SKIP=()

# For each found binary from that list...
for SBINARY in ${PRIVILEGED_BINARIES[@]}
do

    # Replace possible slash '/' character in SBINARY definition so we could use it in sed expressions below
    SBINARY_ESC=${SBINARY//$'/'/$'\/'}

    # Check if this SBINARY wasn't already handled in some of the previous iterations
    if [[ $(sed -ne "/$SBINARY_ESC/p" <<< ${SBINARIES_TO_SKIP[@]}) ]]
    then
        # If so, don't process it second time & go to process next SBINARY
        continue
    fi

    # Search existing audit.rule's content for match. Match criteria:
    # * existing rule is for the same SUID/SGID binary we are currently processing (but
    #   can contain multiple -F path= elements covering multiple SUID/SGID binaries)
    # * existing rule contains all arguments from expected rule form (though can contain
    #   them in arbitrary order)
    BASE_SEARCH=$(sed -e "/-a always,exit/!d" -e "/-F path=${SBINARY_ESC}/!d"	\
                      -e "/-F path=[^[:space:]]\+/!d" -e "/-F perm=.*/!d"	\
                      -e "/-F auid>=500/!d" -e "/-F auid!=4294967295/!d"	\
                      -e "/-k privileged/!d" $AUDIT_RULES)

    # Define expected rule form for this binary
    EXPECTED_RULE="-a always,exit -F path=${SBINARY} -F perm=x -F auid>=500 -F auid!=4294967295 -k privileged"

    # Require execute access type to be set for existing audit rule
    EXEC_ACCESS='x'

    # Search existing audit.rules content for presence of rule pattern for this binary
    if [[ $BASE_SEARCH ]]
    then

        # Current /etc/audit/audit.rules already contains rule for this binary =>
        # Store the exact form of found rule for this binary for further processing
        CONCRETE_RULE=$BASE_SEARCH

        # Select all other SUID/SGID binaries possibly also present in the found rule
        IFS=$'\n' HANDLED_SBINARIES=($(grep -o -e "-F path=[^[:space:]]\+" <<< $CONCRETE_RULE))
        IFS=$' ' HANDLED_SBINARIES=(${HANDLED_SBINARIES[@]//-F path=/})

        # Merge the list of such SUID/SGID binaries found in this iteration with global list ignoring duplicates
        SBINARIES_TO_SKIP=($(for i in "${SBINARIES_TO_SKIP[@]}" "${HANDLED_SBINARIES[@]}"; do echo $i; done | sort -du))

        # Separate CONCRETE_RULE into three sections using hash '#'
        # sign as a delimiter around rule's permission section borders
        CONCRETE_RULE=$(echo $CONCRETE_RULE | sed -n "s/\(.*\)\+\(-F perm=[rwax]\+\)\+/\1#\2#/p")

        # Split CONCRETE_RULE into head, perm, and tail sections using hash '#' delimiter
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
