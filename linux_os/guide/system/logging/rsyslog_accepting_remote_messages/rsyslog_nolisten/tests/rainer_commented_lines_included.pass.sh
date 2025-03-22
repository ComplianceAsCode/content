#!/bin/bash
# platform = multi_platform_all

# Declare variables used for the tests and define the create_rsyslog_test_logs function
source $SHARED/rsyslog_log_utils.sh

# create one test log file
create_rsyslog_test_logs 1

# setup test log file property
chmod 0640 ${RSYSLOG_TEST_LOGS[0]}
chown root.root ${RSYSLOG_TEST_LOGS[0]}

# create test configuration file with commented modules lines
test_conf=${RSYSLOG_CONF_DIR}/test1.conf
cat << EOF > ${test_conf}
# rsyslog test configuration file

#### MODULES ####
# module(load="imtcp")
# input(type="imtcp" port="514")

EOF

# add generic rule plus an include statement
cat << EOF > $RSYSLOG_CONF
# rsyslog configuration file

#### RULES ####
*.*     ${RSYSLOG_TEST_LOGS[0]}

#### MODULES ####
include(file="${test_conf}")

EOF
