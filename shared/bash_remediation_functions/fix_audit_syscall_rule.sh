# Function to fix syscall audit rule for given system call. It is
# based on example audit syscall rule definitions as outlined in
# /usr/share/doc/audit-2.3.7/stig.rules file provided with the audit
# package. It will combine multiple system calls belonging to the same
# syscall group into one audit rule (rather than to create audit rule per
# different system call) to avoid audit infrastructure performance penalty
# in the case of 'one-audit-rule-definition-per-one-system-call'. See:
#
#   https://www.redhat.com/archives/linux-audit/2014-November/msg00009.html
#
# for further details.
#
# Expects five arguments (each of them is required) in the form of:
# * audit tool				tool used to load audit rules,
# 					either 'auditctl', or 'augenrules
# * audit rules' pattern		audit rule skeleton for same syscall
# * syscall group			greatest common string this rule shares
# 					with other rules from the same group
# * architecture			architecture this rule is intended for
# * full form of new rule to add	expected full form of audit rule as to be
# 					added into audit.rules file
#
# Note: The 2-th up to 4-th arguments are used to determine how many existing
# audit rules will be inspected for resemblance with the new audit rule
# (5-th argument) the function is going to add. The rule's similarity check
# is performed to optimize audit.rules definition (merge syscalls of the same
# group into one rule) to avoid the "single-syscall-per-audit-rule" performance
# penalty.
#
# Example call:
#
#	See e.g. 'audit_rules_file_deletion_events.sh' remediation script
#
function fix_audit_syscall_rule {

# Load function arguments into local variables
local tool="$1"
local pattern="$2"
local group="$3"
local arch="$4"
local full_rule="$5"

# Check sanity of the input
if [ $# -ne "5" ]
then
	echo "Usage: fix_audit_syscall_rule 'tool' 'pattern' 'group' 'arch' 'full rule'"
	echo "Aborting."
	exit 1
fi

# Create a list of audit *.rules files that should be inspected for presence and correctness
# of a particular audit rule. The scheme is as follows:
# 
# -----------------------------------------------------------------------------------------
#  Tool used to load audit rules | Rule already defined  |  Audit rules file to inspect    |
# -----------------------------------------------------------------------------------------
#        auditctl                |     Doesn't matter    |  /etc/audit/audit.rules         |
# -----------------------------------------------------------------------------------------
#        augenrules              |          Yes          |  /etc/audit/rules.d/*.rules     |
#        augenrules              |          No           |  /etc/audit/rules.d/$key.rules  |
# -----------------------------------------------------------------------------------------
#
declare -a files_to_inspect

retval=0

# First check sanity of the specified audit tool
if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
then
	echo "Unknown audit rules loading tool: $1. Aborting."
	echo "Use either 'auditctl' or 'augenrules'!"
	return 1
# If audit tool is 'auditctl', then add '/etc/audit/audit.rules'
# file to the list of files to be inspected
elif [ "$tool" == 'auditctl' ]
then
	files_to_inspect+=('/etc/audit/audit.rules' )
# If audit tool is 'augenrules', then check if the audit rule is defined
# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
elif [ "$tool" == 'augenrules' ]
then
	# Extract audit $key from audit rule so we can use it later
	matches=()
	key=$(expr "$full_rule" : '.*-k[[:space:]]\([^[:space:]]\+\)' '|' "$full_rule" : '.*-F[[:space:]]key=\([^[:space:]]\+\)')
	readarray -t matches < <(sed -s -n -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d;F" /etc/audit/rules.d/*.rules)
	if [ $? -ne 0 ]
	then
		retval=1
	fi
	for match in "${matches[@]}"
	do
		files_to_inspect+=("${match}")
	done
	# Case when particular rule isn't defined in /etc/audit/rules.d/*.rules yet
	if [ ${#files_to_inspect[@]} -eq "0" ]
	then
		file_to_inspect="/etc/audit/rules.d/$key.rules"
		files_to_inspect=("$file_to_inspect")
		if [ ! -e "$file_to_inspect" ]
		then
			touch "$file_to_inspect"
			chmod 0640 "$file_to_inspect"
		fi
	fi
fi

#
# Indicator that we want to append $full_rule into $audit_file by default
local append_expected_rule=0

for audit_file in "${files_to_inspect[@]}"
do
	# Filter existing $audit_file rules' definitions to select those that:
	# * follow the rule pattern, and
	# * meet the hardware architecture requirement, and
	# * are current syscall group specific
	readarray -t existing_rules < <(sed -e "\;${pattern};!d" -e "/${arch}/!d" -e "/${group}/!d"  "$audit_file")
	if [ $? -ne 0 ]
	then
		retval=1
	fi

	# Process rules found case-by-case
	for rule in "${existing_rules[@]}"
	do
		# Found rule is for same arch & key, but differs (e.g. in count of -S arguments)
		if [ "${rule}" != "${full_rule}" ]
		then
			# If so, isolate just '(-S \w)+' substring of that rule
			rule_syscalls=$(echo "$rule" | grep -o -P '(-S \w+ )+')
			# Check if list of '-S syscall' arguments of that rule is subset
			# of '-S syscall' list of expected $full_rule
			if grep -q -- "$rule_syscalls" <<< "$full_rule"
			then
				# Rule is covered (i.e. the list of -S syscalls for this rule is
				# subset of -S syscalls of $full_rule => existing rule can be deleted
				# Thus delete the rule from audit.rules & our array
				sed -i -e "\;${rule};d" "$audit_file"
				if [ $? -ne 0 ]
				then
					retval=1
				fi
				existing_rules=("${existing_rules[@]//$rule/}")
			else
				# Rule isn't covered by $full_rule - it besides -S syscall arguments
				# for this group contains also -S syscall arguments for other syscall
				# group. Example: '-S lchown -S fchmod -S fchownat' => group='chown'
				# since 'lchown' & 'fchownat' share 'chown' substring
				# Therefore:
				# * 1) delete the original rule from audit.rules
				# (original '-S lchown -S fchmod -S fchownat' rule would be deleted)
				# * 2) delete the -S syscall arguments for this syscall group, but
				# keep those not belonging to this syscall group
				# (original '-S lchown -S fchmod -S fchownat' would become '-S fchmod'
				# * 3) append the modified (filtered) rule again into audit.rules
				# if the same rule not already present
				#
				# 1) Delete the original rule
				sed -i -e "\;${rule};d" "$audit_file"
				if [ $? -ne 0 ]
				then
					retval=1
				fi

				# 2) Delete syscalls for this group, but keep those from other groups
				# Convert current rule syscall's string into array splitting by '-S' delimiter
				IFS_BKP="$IFS"
				IFS=$'-S'
				read -a rule_syscalls_as_array <<< "$rule_syscalls"
				# Reset IFS back to default
				IFS="$IFS_BKP"
				# Splitting by "-S" can't be replaced by the readarray functionality easily

				# Declare new empty string to hold '-S syscall' arguments from other groups
				new_syscalls_for_rule=''
				# Walk through existing '-S syscall' arguments
				for syscall_arg in "${rule_syscalls_as_array[@]}"
				do
					# Skip empty $syscall_arg values
					if [ "$syscall_arg" == '' ]
					then
						continue
					fi
					# If the '-S syscall' doesn't belong to current group add it to the new list
					# (together with adding '-S' delimiter back for each of such item found)
					if grep -q -v -- "$group" <<< "$syscall_arg"
					then
						new_syscalls_for_rule="$new_syscalls_for_rule -S $syscall_arg"
					fi
				done
				# Replace original '-S syscall' list with the new one for this rule
				updated_rule=${rule//$rule_syscalls/$new_syscalls_for_rule}
				# Squeeze repeated whitespace characters in rule definition (if any) into one
				updated_rule=$(echo "$updated_rule" | tr -s '[:space:]')
				# 3) Append the modified / filtered rule again into audit.rules
				#    (but only in case it's not present yet to prevent duplicate definitions)
				if ! grep -q -- "$updated_rule" "$audit_file"
				then
					echo "$updated_rule" >> "$audit_file"
				fi
			fi
		else
			# $audit_file already contains the expected rule form for this
			# architecture & key => don't insert it second time
			append_expected_rule=1
		fi
	done

	# We deleted all rules that were subset of the expected one for this arch & key.
	# Also isolated rules containing system calls not from this system calls group.
	# Now append the expected rule if it's not present in $audit_file yet
	if [[ ${append_expected_rule} -eq "0" ]]
	then
		echo "$full_rule" >> "$audit_file"
	fi
done

return $retval

}
