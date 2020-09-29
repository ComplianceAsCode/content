#!/bin/bash
# platform = Red Hat Enterprise Linux 8,multi_platform_fedora,Oracle Linux 8

# Check rsyslog.conf with root user log from rules and
# non root user log from include() fails.

source $SHARED/rsyslog_log_utils.sh

USER_ROOT=root

USER_TEST=testssg
useradd $USER_TEST

# setup test data
create_rsyslog_test_logs 3

# setup test log files ownership
chown $USER_ROOT ${RSYSLOG_TEST_LOGS[0]}
chown $USER_ROOT ${RSYSLOG_TEST_LOGS[1]}
chown $USER_TEST ${RSYSLOG_TEST_LOGS[2]}

# create test configuration file
test_conf=${RSYSLOG_TEST_DIR}/test1.conf
cat << EOF > ${test_conf}
# rsyslog configuration file

#### RULES ####

*.*     ${RSYSLOG_TEST_LOGS[1]}
EOF

# create test2 configuration file
test_conf2=${RSYSLOG_TEST_DIR}/test2.conf
cat << EOF > ${test_conf2}
# rsyslog configuration file

#### RULES ####

*.*     ${RSYSLOG_TEST_LOGS[2]}
EOF

# create rsyslog.conf configuration file
cat << EOF > $RSYSLOG_CONF
# rsyslog configuration file

#### RULES ####

*.*     ${RSYSLOG_TEST_LOGS[0]}

#### MODULES ####

include(file="${test_conf}")

\$IncludeConfig ${test_conf2}
EOF
