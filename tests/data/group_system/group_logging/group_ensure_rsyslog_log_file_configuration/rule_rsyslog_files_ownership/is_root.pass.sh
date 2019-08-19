#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss
# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol

# Check if log file with root user in rsyslog.conf passes.

source ../rsyslog_log_utils.sh

USER=root

# setup test data
create_rsyslog_test_logs 1

# setup test log file ownership
chown $USER ${RSYSLOG_TEST_LOGS[0]}

# add rule with root user owned log file
cat << EOF > $RSYSLOG_CONF
# rsyslog configuration file

#### RULES ####

*.*        ${RSYSLOG_TEST_LOGS[0]}

EOF
