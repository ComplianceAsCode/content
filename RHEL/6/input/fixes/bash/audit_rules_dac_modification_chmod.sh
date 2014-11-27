
# audit.rules file to operate at
AUDIT_RULES_FILE="/etc/audit/audit.rules"

# General form / skeleton of an audit rule to search for
BASE_SEARCH_RULE='-a always,exit .* -F auid>=500 -F auid!=4294967295 -k perm_mod'

# System calls group to search for
SYSCALL_GROUP="chmod"

# Retrieve hardware architecture of the underlying system
[ $(getconf LONG_BIT) = "32" ] && ARCHS=("b32") || ARCHS=("b32" "b64")

# Perform the remediation depending on the system's architecture:
# * on 32 bit system, operate just at '-F arch=b32' audit rules
# * on 64 bit system, operate at both '-F arch=b32' & '-F arch=b64' audit rules
for ARCH in ${ARCHS[@]}
do

  # Create expected audit rule form for particular system call & architecture
  EXPECTED_RULE="-a always,exit -F arch=${ARCH} -S chmod -S fchmod -S fchmodat -F auid>=500 -F auid!=4294967295 -k perm_mod"

  # Indicator that we want to append $EXPECTED_RULE for key & arch into
  # audit.rules by default
  APPEND_EXPECTED_RULE=0

  # From all the existing /etc/audit.rule definitions select those, which:
  # * follow the common audit rule form ($BASE_SEARCH_RULE above)
  # * meet the hardware architecture requirement, and
  # * are current $SYSCALL_GROUP specific
  IFS=$'\n' EXISTING_KEY_ARCH_RULES=($(sed -e "/${BASE_SEARCH_RULE}/!d" -e "/${ARCH}/!d" -e "/${SYSCALL_GROUP}/!d"  ${AUDIT_RULES_FILE}))

  # Process found rules case by case
  for RULE in ${EXISTING_KEY_ARCH_RULES[@]}
  do
    # Found rule is for same arch & syscall group, but differs slightly (in count of -S arguments)
    if [ ${RULE} != ${EXPECTED_RULE} ]
    then
      # If so, isolate just '-S syscall' substring of that rule
      RULE_SYSCALLS=$(echo ${RULE} | grep -o -P '(-S \w+ )+')

        # Check if list of '-S syscall' arguments of that rule is a subset
        # '-S syscall' list from the expected form ($EXPECTED_RULE)
        if [ $(echo ${EXPECTED_RULE} | grep -- ${RULE_SYSCALLS}) ]
        then
          # If so, this audit rule is covered when we append expected rule
          # later & therefore the rule can be deleted.
          #
          # Thus delete the rule from both - the audit.rules file and
          # our $EXISTING_KEY_ARCH_RULES array
          sed -i -e "/${RULE}/d" ${AUDIT_RULES_FILE}
          EXISTING_KEY_ARCH_RULES=(${EXISTING_KEY_ARCH_RULES[@]//${RULE}/})
        else
          # Rule isn't covered by $EXPECTED_RULE - in other words it besides
          # $SYSCALL_GROUP -S arguments contains also -S arguments for other
          # syscall group. Example: '-S chmod -S lchown'
          #
          # Therefore:
          # * delete the original rule for arch & key from audit.rules
          #   (original '-S chmod -S lchown' rule would be deleted)
          # * delete $SYSCALL_GROUP -S arguments from the rule,
          #   but keep those not from this $SYSCALL_GROUP
          #   (original '-S chmod -S lchown' would become '-S lchown')
          # * append the modified (filtered) rule again into audit.rules
          #   if the same rule not already present
          #   (new rule for same arch & key with '-S lchown' would be appended
          #    if not present yet)
          sed -i -e "/${RULE}/d" ${AUDIT_RULES_FILE}
          # Drop ' -S (chmod|fchmod|fchmodat)' from the rule's system calls list
          NEW_SYSCALLS_FOR_RULE=$(echo ${RULE_SYSCALLS} | sed -r -e "s/[\s]*-S (fchmodat|fchmod|chmod)//g")
          UPDATED_RULE=$(echo ${RULE} | sed "s/${RULE_SYSCALLS}/${NEW_SYSCALLS_FOR_RULE}/g")
          # Squeeze repeated whitespace characters in rule definition (if any) into one
          UPDATED_RULE=$(echo ${UPDATED_RULE} | tr -s '[:space:]')
          # Insert updated rule into /etc/audit/audit.rules only in case it's not
          # present yet to prevent duplicate same rules
          if [ ! $(grep -- ${UPDATED_RULE} ${AUDIT_RULES_FILE}) ]
          then
            echo ${UPDATED_RULE} >> ${AUDIT_RULES_FILE}
          fi
        fi

    else
      # /etc/audit/audit.rules already contains the expected rule form for this
      # architecture & key => don't insert it second time
      APPEND_EXPECTED_RULE=1
    fi
  done

  # We deleted all rules that were subset of the expected one for this arch & key.
  # Also isolated rules containing system calls not from this system calls group.
  # Now append the expected rule if it's not present in audit.rules yet
  if [[ ${APPEND_EXPECTED_RULE} -eq "0" ]]
  then
    echo ${EXPECTED_RULE} >> ${AUDIT_RULES_FILE}
  fi
done
