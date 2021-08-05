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
# Expects seven arguments (each of them is required) in the form of:
# * audit tool				tool used to load audit rules,
# 					either 'auditctl', or 'augenrules
# * action_arch_filters		The action and arch filters of the rule
#					For example, "-a always,exit -F arch=b64"
# * other_filters			Other filters that may characterize the rule:
#					For example, "-F a2&03 -F path=/etc/passwd"
# * auid_filters			The auid filters of the rule
#					For example, "-F auid>=1000 -F auid!=unset"
# * syscall					The syscall to ensure presense among audit rules
#					For example, "chown"
# * syscall_groupings		Other syscalls that can be grouped with 'syscall'
#					as a space separated list.
#					For example, "fchown lchown fchownat"
# * key						The key to use when appending a new rule
#
# Notes:
# - The 2-nd up to 4-th arguments are used to determine how many existing
# audit rules will be inspected for resemblance with the new audit rule
# the function is going to add.
# - The function's similarity check uses the 5-th argument to optimize audit
# rules definitions (merge syscalls of the same group into one rule) to avoid
# the "single-syscall-per-audit-rule" performance penalty.
# - The key argument (7-th argument) is not used when the syscall is grouped to an
# existing audit rule. The audit rule will retain the key it already had.

function fix_audit_syscall_rule {

# Load function arguments into local variables
local tool="$1"
local action_arch_filters="$2"
local other_filters="$3"
local auid_filters="$4"
local syscall_a
read -a syscall_a <<< "$5"
local syscall_grouping
read -a syscall_grouping <<< "$6"
local key="$7"

# Check sanity of the input
if [ $# -ne "7" ]
then
	echo "Usage: fix_audit_syscall_rule 'tool' 'action_arch_filters' 'other_filters' 'auid_filters' 'syscall' 'syscall_grouping' 'key'"
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
	default_file="/etc/audit/audit.rules"
	files_to_inspect+=('/etc/audit/audit.rules' )
# If audit tool is 'augenrules', then check if the audit rule is defined
# If rule is defined, add '/etc/audit/rules.d/*.rules' to the list for inspection
# If rule isn't defined yet, add '/etc/audit/rules.d/$key.rules' to the list for inspection
elif [ "$tool" == 'augenrules' ]
then
	default_file="/etc/audit/rules.d/${key}.rules"
	# As other_filters may include paths, lets use a different delimiter for it
	# The "F" script expression tells sed to print the filenames where the expressions matched
	readarray -t files_to_inspect < <(sed -s -n -e "/${action_arch_filters}/!d" -e "\#${other_filters}#!d" -e "/${auid_filters}/!d" -e "F" /etc/audit/rules.d/*.rules)
	if [ $? -ne 0 ]
	then
		retval=1
	fi
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
# Indicator that we want to append $full_rule into $audit_file or edit a rule in it
local append_expected_rule=0

for audit_file in "${files_to_inspect[@]}"
do
	# Filter existing $audit_file rules' definitions to select those that satisfy the rule pattern,
	# i.e, collect rules that match:
	# * the action, list and arch, (2-nd argument)
	# * the other filters, (3-rd argument)
	# * the auid filters, (4-rd argument)
	readarray -t similar_rules < <(sed -e "/${action_arch_filters}/!d"  -e "\#${other_filters}#!d" -e "/${auid_filters}/!d" "$audit_file")
	if [ $? -ne 0 ]
	then
		retval=1
	fi

	local candidate_rules=()
	# Filter out rules that have more fields then required. This will remove rules more specific than the required scope
	for s_rule in "${similar_rules[@]}"
	do
		# Strip all the options and fields we know of,
		# than check if there was any field left over
		extra_fields=$(sed -E -e "s/${action_arch_filters}//"  -e "s#${other_filters}##" -e "s/${auid_filters}//" -e "s/((:?-S [[:alnum:],]+)+)//g" -e "s/-F key=\w+|-k \w+//"<<< "$s_rule")
		grep -q -- "-F" <<< "$extra_fields"
		if [ $? -ne 0 ]
		then
			candidate_rules+=("$s_rule")
		fi
	done

	if [[ ${#syscall_a[@]} -ge 1 ]]
	then
		# Check if the syscall we want is present in any of the similar existing rules
		for rule in "${candidate_rules[@]}"
		do
			rule_syscalls=$(echo "$rule" | grep -o -P '(-S [\w,]+)+' | xargs)
			local all_syscalls_found=0
			for syscall in "${syscall_a[@]}"
			do
				grep -q -- "\b${syscall}\b" <<< "$rule_syscalls"
				if [ $? -eq 1 ]
				then
					# A syscall was not found in the candidate rule
					all_syscalls_found=1
				fi
			done
			if [[ $all_syscalls_found -eq 0 ]]
			then
				# We found a rule with all the syscall(s) we want
				return $retval
			fi

			# Check if this rule can be grouped with our target syscall and keep track of it
			for syscall_g in "${syscall_grouping[@]}"
			do
				if grep -q -- "\b${syscall_g}\b" <<< "$rule_syscalls"
				then
					local file_to_edit=${audit_file}
					local rule_to_edit=${rule}
					local rule_syscalls_to_edit=${rule_syscalls}
				fi
			done
		done
	else
		# If there is any candidate rule, it is compliant.
		if [[ $candidate_rules ]]
		then
			return $retval
		fi
	fi
done


# We checked all rules that matched the expected resemblance patter (action, arch & auid)
# At this point we know if we need to either append the $full_rule or group
# the syscall together with an exsiting rule

# Append the full_rule if it cannot be grouped to any other rule
if [ -z ${rule_to_edit+x} ]
then
	# Build full_rule while avoid adding double spaces when other_filters is empty
	if [[ ${syscall_a} ]]
	then
		local syscall_string=""
		for syscall in "${syscall_a[@]}"
		do
			syscall_string+=" -S $syscall"
		done
	fi
	local other_string=$([[ $other_filters ]] && echo " $other_filters")
	local auid_string=$([[ $auid_filters ]] && echo " $auid_filters")
	local full_rule="${action_arch_filters}${syscall_string}${other_string}${auid_string} -F key=${key}"
	echo "$full_rule" >> "$default_file"
else
	# Check if the syscalls are declared as a comma separated list or
	# as multiple -S parameters
	if grep -q -- "," <<< "${rule_syscalls_to_edit}"
	then
		delimiter=","
	else
		delimiter=" -S "
	fi
	new_grouped_syscalls="${rule_syscalls_to_edit}"
	for syscall in "${syscall_a[@]}"
	do
		grep -q -- "\b${syscall}\b" <<< "${rule_syscalls_to_edit}"
		if [ $? -eq 1 ]
		then
			# A syscall was not found in the candidate rule
			new_grouped_syscalls+="${delimiter}${syscall}"
		fi
	done

	# Group the syscall in the rule
	sed -i -e "\#${rule_to_edit}#s#${rule_syscalls_to_edit}#${new_grouped_syscalls}#" "$file_to_edit"
	if [ $? -ne 0 ]
	then
		retval=1
	fi
fi

return $retval

}
