#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_sle

# Check rsyslog.conf with log file permissions 0600 from rules and
# log file permissions 0600 from $IncludeConfig passes.
# test $IncludeConfig with wildcard (*.conf)

source $SHARED/rsyslog_log_utils.sh

PERMS=0600

# setup test data
create_rsyslog_test_logs 2

# setup test log files and permissions
chmod $PERMS ${RSYSLOG_TEST_LOGS[0]}
chmod $PERMS ${RSYSLOG_TEST_LOGS[1]}

# create test configuration file
test_conf=${RSYSLOG_TEST_DIR}/test1.conf
cat << EOF > ${test_conf}
# rsyslog configuration file

#### RULES ####

*.*     ${RSYSLOG_TEST_LOGS[1]}
EOF

# create rsyslog.conf configuration file
cat << EOF > $RSYSLOG_CONF
# rsyslog configuration file

#### RULES ####

*.*     ${RSYSLOG_TEST_LOGS[0]}

#### MODULES ####

\$IncludeConfig ${RSYSLOG_TEST_DIR}/*.conf
EOF
