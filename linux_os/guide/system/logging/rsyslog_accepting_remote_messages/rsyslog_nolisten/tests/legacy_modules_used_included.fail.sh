#!/bin/bash
# platform = multi_platform_all

# Declare variables used for the tests and define the create_rsyslog_test_logs function
source $SHARED/rsyslog_log_utils.sh

# create one test log file
create_rsyslog_test_logs 1

# setup test log file property
chmod 0640 ${RSYSLOG_TEST_LOGS[0]}
chown root.root ${RSYSLOG_TEST_LOGS[0]}

# create test configuration file with modules lines defined
test_conf=${RSYSLOG_CONF_DIR}/test1.conf
cat << EOF > ${test_conf}
# rsyslog test configuration file

#### MODULES ####
\$ModLoad imtcp
\$InputTCPServerRun 5000
\$ModLoad imudp
\$UDPServerRun 5000
\$ModLoad imrelp
\$InputRELPServerRun 5000

EOF

# add generic rule plus an include statement
cat << EOF > $RSYSLOG_CONF
# rsyslog configuration file

#### RULES ####
*.*     ${RSYSLOG_TEST_LOGS[0]}

#### MODULES ####
\$IncludeConfig ${test_conf}

EOF
