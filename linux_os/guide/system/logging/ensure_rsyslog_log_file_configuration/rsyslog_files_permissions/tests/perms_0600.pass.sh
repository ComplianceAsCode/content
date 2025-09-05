#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss
# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol

# Check if log file with permissions 0600 in rsyslog.conf passes.

source $SHARED/rsyslog_log_utils.sh

PERMS=0600

# setup test data
create_rsyslog_test_logs 4

# setup all files with incorrect permission
chmod 0601 "${RSYSLOG_TEST_LOGS[@]}"

# setup the real logfile with correct permissions
chmod $PERMS "${RSYSLOG_TEST_LOGS[0]}"

# add rule with 0600 permissions log file
cat << EOF > $RSYSLOG_CONF
# rsyslog configuration file

#### RULES ####

*.*        ${RSYSLOG_TEST_LOGS[0]}

 *.*        ${RSYSLOG_TEST_LOGS[1]}

authpriv.*        /nonexistent_file

# *.*        /irrelevant_file

\$something /irrelevant_file

EOF
