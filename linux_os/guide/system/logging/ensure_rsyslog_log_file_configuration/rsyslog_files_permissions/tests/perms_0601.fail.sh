#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss
# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol

# Check if log file with permissions 0601 in rsyslog.conf fails.

source $SHARED/rsyslog_log_utils.sh

PERMS=0601

# setup test data
create_rsyslog_test_logs 3

# setup test log file and permissions
chmod $PERMS ${RSYSLOG_TEST_LOGS[0]}

# add rule with 0601 permissions log file
cat << EOF > $RSYSLOG_CONF
# rsyslog configuration file

#### RULES ####

*.*     ${RSYSLOG_TEST_LOGS[0]}

cron.*        /nonexistent_file

 authpriv.*        /irrelevant_file

# *.*        /irrelevant_file

\$something /irrelevant_file

something.*	${RSYSLOG_TEST_LOGS[2]}

EOF
