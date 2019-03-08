# platform = Red Hat Enterprise Linux 8

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions
include_merge_files_by_lines

MASTER_FILE="/usr/share/doc/audit/rules/30-ospp-v42.rules"
SAMPLE_FILE="/etc/audit/rules.d/30-ospp-v42-remediation.rules"

# First perform the remediation of the syscall rule
# Retrieve hardware architecture of the underlying system
if [ "$(getconf LONG_BIT)" = "32" ]; then
	# 32 bit rules
	merge_first_lines_to_second_on_indices $MASTER_FILE $SAMPLE_FILE "20 24"
else
	# 32 bit and 64 bit rules
	merge_first_lines_to_second_on_indices $MASTER_FILE $SAMPLE_FILE "20 21 24 25"
fi
