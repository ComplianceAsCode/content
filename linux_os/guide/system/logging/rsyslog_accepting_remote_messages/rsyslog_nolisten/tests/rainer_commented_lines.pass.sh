#!/bin/bash
# platform = multi_platform_all

# Declare variables used for the tests and define the create_rsyslog_test_logs function
source $SHARED/rsyslog_log_utils.sh

# create one test log file
create_rsyslog_test_logs 1

# setup test log file property
chmod 0640 ${RSYSLOG_TEST_LOGS[0]}
chown root.root ${RSYSLOG_TEST_LOGS[0]}

# add commented modules lines to main configuration file
cat << EOF > $RSYSLOG_CONF
# rsyslog configuration file

#### MODULES ####
# module(load="imtcp")
# input(type="imtcp" port="514")

#### RULES ####
*.*     ${RSYSLOG_TEST_LOGS[0]}

EOF
