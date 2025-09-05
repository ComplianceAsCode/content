# Function to fix audit file system object watch rule for given path:
# * if rule exists, also verifies the -w bits match the requirements
# * if rule doesn't exist yet, appends expected rule form to $files_to_inspect
#   audit rules file, depending on the tool which was used to load audit rules
#
# Expects four arguments (each of them is required) in the form of:
# * audit tool				tool used to load audit rules,
# 					either 'auditctl', or 'augenrules'
# * path                        	value of -w audit rule's argument
# * required access bits        	value of -p audit rule's argument
# * key                         	value of -k audit rule's argument
#
# Example call:
#
#       fix_audit_watch_rule "auditctl" "/etc/localtime" "wa" "audit_time_rules"
#
function fix_audit_watch_rule {

# Load function arguments into local variables
local tool="$1"
local path="$2"
local required_access_bits="$3"
local key="$4"

# Check sanity of the input
if [ $# -ne "4" ]
then
	echo "Usage: fix_audit_watch_rule 'tool' 'path' 'bits' 'key'"
	echo "Aborting."
	exit 1
fi

# Create a list of audit *.rules files that should be inspected for presence and correctness
# of a particular audit rule. The scheme is as follows:
#
# -----------------------------------------------------------------------------------------
# Tool used to load audit rules	| Rule already defined	|  Audit rules file to inspect	  |
# -----------------------------------------------------------------------------------------
#	auditctl		|     Doesn't matter	|  /etc/audit/audit.rules	  |
# -----------------------------------------------------------------------------------------
# 	augenrules		|          Yes		|  /etc/audit/rules.d/*.rules	  |
# 	augenrules		|          No		|  /etc/audit/rules.d/$key.rules  |
# -----------------------------------------------------------------------------------------
declare -a files_to_inspect
files_to_inspect=()

# Check sanity of the specified audit tool
if [ "$tool" != 'auditctl' ] && [ "$tool" != 'augenrules' ]
then
	echo "Unknown audit rules loading tool: $1. Aborting."
	echo "Use either 'auditctl' or 'augenrules'!"
	exit 1
# If the audit tool is 'auditctl', then add '/etc/audit/audit.rules'
# into the list of files to be inspected
elif [ "$tool" == 'auditctl' ]
then
	files_to_inspect+=('/etc/audit/audit.rules')
# If the audit is 'augenrules', then check if rule is already defined
# If rule is defined, add '/etc/audit/rules.d/*.rules' to list of files for inspection.
# If rule isn't defined, add '/etc/audit/rules.d/$key.rules' to list of files for inspection.
elif [ "$tool" == 'augenrules' ]
then
	readarray -t matches < <(grep -P "[\s]*-w[\s]+$path" /etc/audit/rules.d/*.rules)

	# For each of the matched entries
	for match in "${matches[@]}"
	do
		# Extract filepath from the match
		rulesd_audit_file=$(echo $match | cut -f1 -d ':')
		# Append that path into list of files for inspection
		files_to_inspect+=("$rulesd_audit_file")
	done
	# Case when particular audit rule isn't defined yet
	if [ "${#files_to_inspect[@]}" -eq "0" ]
	then
		# Append '/etc/audit/rules.d/$key.rules' into list of files for inspection
		local key_rule_file="/etc/audit/rules.d/$key.rules"
		# If the $key.rules file doesn't exist yet, create it with correct permissions
		if [ ! -e "$key_rule_file" ]
		then
			touch "$key_rule_file"
			chmod 0640 "$key_rule_file"
		fi

		files_to_inspect+=("$key_rule_file")
	fi
fi

# Finally perform the inspection and possible subsequent audit rule
# correction for each of the files previously identified for inspection
for audit_rules_file in "${files_to_inspect[@]}"
do

	# Check if audit watch file system object rule for given path already present
	if grep -q -P -- "[\s]*-w[\s]+$path" "$audit_rules_file"
	then
		# Rule is found => verify yet if existing rule definition contains
		# all of the required access type bits

		# Escape slashes in path for use in sed pattern below
		local esc_path=${path//$'/'/$'\/'}
		# Define BRE whitespace class shortcut
		local sp="[[:space:]]"
		# Extract current permission access types (e.g. -p [r|w|x|a] values) from audit rule
		current_access_bits=$(sed -ne "s/$sp*-w$sp\+$esc_path$sp\+-p$sp\+\([rxwa]\{1,4\}\).*/\1/p" "$audit_rules_file")
		# Split required access bits string into characters array
		# (to check bit's presence for one bit at a time)
		for access_bit in $(echo "$required_access_bits" | grep -o .)
		do
			# For each from the required access bits (e.g. 'w', 'a') check
			# if they are already present in current access bits for rule.
			# If not, append that bit at the end
			if ! grep -q "$access_bit" <<< "$current_access_bits"
			then
				# Concatenate the existing mask with the missing bit
				current_access_bits="$current_access_bits$access_bit"
			fi
		done
		# Propagate the updated rule's access bits (original + the required
		# ones) back into the /etc/audit/audit.rules file for that rule
		sed -i "s/\($sp*-w$sp\+$esc_path$sp\+-p$sp\+\)\([rxwa]\{1,4\}\)\(.*\)/\1$current_access_bits\3/" "$audit_rules_file"
	else
		# Rule isn't present yet. Append it at the end of $audit_rules_file file
		# with proper key

		echo "-w $path -p $required_access_bits -k $key" >> "$audit_rules_file"
	fi
done
}
