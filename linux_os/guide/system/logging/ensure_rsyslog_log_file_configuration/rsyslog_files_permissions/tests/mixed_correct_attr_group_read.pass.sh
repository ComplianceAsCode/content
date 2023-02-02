#!/bin/bash
# platform = multi_platform_sle,multi_platform_ubuntu

# Declare variables used for the tests and define the create_rsyslog_test_logs function
source $SHARED/rsyslog_log_utils.sh

CHATTR="chmod"
ATTR_VALUE="0640"

# create three test log file
create_rsyslog_test_logs 2

# setup test log file property
$CHATTR $ATTR_VALUE ${RSYSLOG_TEST_LOGS[0]}
$CHATTR $ATTR_VALUE ${RSYSLOG_TEST_LOGS[1]}

# add rules with both syntax for different test log files
cat << EOF > $RSYSLOG_CONF
# rsyslog configuration file

#### RULES ####
*.*     ${RSYSLOG_TEST_LOGS[0]}
*.*     action(type="omfile" FileCreateMode="0640" fileOwner="root" fileGroup="hoiadm" File="${RSYSLOG_TEST_LOGS[1]}")

EOF
