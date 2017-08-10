# Function to perform remediation for 'audit_rules_privileged_commands' rule
#
# Expects two arguments:
#
# audit_tool		tool used to load audit rules
# 			One of 'auditctl' or 'augenrules'
#
# min_auid		Minimum original ID the user logged in with
# 			'500' for RHEL-6 and before, '1000' for RHEL-7 and after.
#
# Example Call(s):
#
#      perform_audit_rules_privileged_commands_remediation "auditctl" "500"
#      perform_audit_rules_privileged_commands_remediation "augenrules"	"1000"
#
function perform_audit_rules_privileged_commands_remediation {
#
# Load function arguments into local variables
local tool="$1"
local min_auid="$2"

# Check sanity of the input
if [ $# -ne "2" ]
then
	echo "Usage: perform_audit_rules_privileged_commands_remediation 'auditctl | augenrules' '500 | 1000'"
	echo "Aborting."
	exit 1
fi

declare -a files_to_inspect=()

# Check sanity of the specified audit tool
if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
then
	echo "Unknown audit rules loading tool: $1. Aborting."
	echo "Use either 'auditctl' or 'augenrules'!"
	exit 1
# If the audit tool is 'auditctl', then:
# * add '/etc/audit/audit.rules'to the list of files to be inspected,
# * specify '/etc/audit/audit.rules' as the output audit file, where
#   missing rules should be inserted
elif [ "$tool" == 'auditctl' ]
then
	files_to_inspect=("/etc/audit/audit.rules")
	output_audit_file="/etc/audit/audit.rules"
#
# If the audit tool is 'augenrules', then:
# * add '/etc/audit/rules.d/*.rules' to the list of files to be inspected
#   (split by newline),
# * specify /etc/audit/rules.d/privileged.rules' as the output file, where
#   missing rules should be inserted
elif [ "$tool" == 'augenrules' ]
then
	IFS=$'\n' files_to_inspect=($(find /etc/audit/rules.d -maxdepth 1 -type f -name *.rules -print))
	output_audit_file="/etc/audit/rules.d/privileged.rules"
fi

# Obtain the list of SUID/SGID binaries on the particular system (split by newline)
# into privileged_binaries array
IFS=$'\n' privileged_binaries=($(find / -xdev -type f -perm -4000 -o -type f -perm -2000 2>/dev/null))

# Keep list of SUID/SGID binaries that have been already handled within some previous iteration
declare -a sbinaries_to_skip=()

# For each found sbinary in privileged_binaries list
for sbinary in "${privileged_binaries[@]}"
do

	# Replace possible slash '/' character in sbinary definition so we could use it in sed expressions below
	sbinary_esc=${sbinary//$'/'/$'\/'}
	# Check if this sbinary wasn't already handled in some of the previous iterations
	# Return match only if whole sbinary definition matched (not in the case just prefix matched!!!)
	if [[ $(sed -ne "/${sbinary_esc}$/p" <<< ${sbinaries_to_skip[@]}) ]]
	then
		# If so, don't process it second time & go to process next sbinary
		continue
	fi

	# Reset the counter of inspected files when starting to check
	# presence of existing audit rule for new sbinary
	local count_of_inspected_files=0

	# For each audit rules file from the list of files to be inspected
	for afile in "${files_to_inspect[@]}"
	do

		# Search current audit rules file's content for match. Match criteria:
		# * existing rule is for the same SUID/SGID binary we are currently processing (but
		#   can contain multiple -F path= elements covering multiple SUID/SGID binaries)
		# * existing rule contains all arguments from expected rule form (though can contain
		#   them in arbitrary order)
	
		base_search=$(sed -e "/-a always,exit/!d" -e "/-F path=${sbinary_esc}$/!d"   \
		    		  -e "/-F path=[^[:space:]]\+/!d" -e "/-F perm=.*/!d"       \
				  -e "/-F auid>=${min_auid}/!d" -e "/-F auid!=4294967295/!d"  \
				  -e "/-k privileged/!d" $afile)

		# Increase the count of inspected files for this sbinary
		count_of_inspected_files=$((count_of_inspected_files + 1))

		# Define expected rule form for this binary
		expected_rule="-a always,exit -F path=${sbinary} -F perm=x -F auid>=${min_auid} -F auid!=4294967295 -k privileged"

		# Require execute access type to be set for existing audit rule
		exec_access='x'

		# Search current audit rules file's content for presence of rule pattern for this sbinary
		if [[ $base_search ]]
		then

			# Current audit rules file already contains rule for this binary =>
			# Store the exact form of found rule for this binary for further processing
			concrete_rule=$base_search

			# Select all other SUID/SGID binaries possibly also present in the found rule
			IFS=$'\n' handled_sbinaries=($(grep -o -e "-F path=[^[:space:]]\+" <<< $concrete_rule))
			IFS=$' ' handled_sbinaries=(${handled_sbinaries[@]//-F path=/})

			# Merge the list of such SUID/SGID binaries found in this iteration with global list ignoring duplicates
			sbinaries_to_skip=($(for i in "${sbinaries_to_skip[@]}" "${handled_sbinaries[@]}"; do echo $i; done | sort -du))

			# Separate concrete_rule into three sections using hash '#'
			# sign as a delimiter around rule's permission section borders
			concrete_rule=$(echo $concrete_rule | sed -n "s/\(.*\)\+\(-F perm=[rwax]\+\)\+/\1#\2#/p")

			# Split concrete_rule into head, perm, and tail sections using hash '#' delimiter
			IFS=$'#' read rule_head rule_perm rule_tail <<<  "$concrete_rule"

			# Extract already present exact access type [r|w|x|a] from rule's permission section
			access_type=${rule_perm//-F perm=/}

			# Verify current permission access type(s) for rule contain 'x' (execute) permission
			if ! grep -q "$exec_access" <<< "$access_type"
			then

				# If not, append the 'x' (execute) permission to the existing access type bits
				access_type="$access_type$exec_access"
				# Reconstruct the permissions section for the rule
				new_rule_perm="-F perm=$access_type"
				# Update existing rule in current audit rules file with the new permission section
				sed -i "s#${rule_head}\(.*\)${rule_tail}#${rule_head}${new_rule_perm}${rule_tail}#" $afile

			fi

		# If the required audit rule for particular sbinary wasn't found yet, insert it under following conditions:
		#
		# * in the "auditctl" mode of operation insert particular rule each time
		#   (because in this mode there's only one file -- /etc/audit/audit.rules to be inspected for presence of this rule),
		#
		# * in the "augenrules" mode of operation insert particular rule only once and only in case we have already
		#   searched all of the files from /etc/audit/rules.d/*.rules location (since that audit rule can be defined
		#   in any of those files and if not, we want it to be inserted only once into /etc/audit/rules.d/privileged.rules file)
		#
		elif [ "$tool" == "auditctl" ] || [[ "$tool" == "augenrules" && $count_of_inspected_files -eq "${#files_to_inspect[@]}" ]]
		then

			# Current audit rules file's content doesn't contain expected rule for this
			# SUID/SGID binary yet => append it
			echo $expected_rule >> $output_audit_file
		fi

	done

done
}	
