#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol

# Check rsyslog.conf with log file permissions 0600 from rules and
# log file permissions 0601 from $IncludeConfig fails.

source $SHARED/rsyslog_log_utils.sh

PERMS_PASS=0600
PERMS_FAIL=0601

# setup test data
create_rsyslog_test_logs 3

# setup test log files and permissions
chmod $PERMS_PASS ${RSYSLOG_TEST_LOGS[0]}
chmod $PERMS_FAIL ${RSYSLOG_TEST_LOGS[1]}
chmod $PERMS_FAIL ${RSYSLOG_TEST_LOGS[2]}

# create test configuration file
conf_subdir=${RSYSLOG_TEST_DIR}/subdir
mkdir ${conf_subdir}
test_subdir_conf=${conf_subdir}/test_subdir.conf
test_conf=${RSYSLOG_TEST_DIR}/test.conf
cat << EOF > ${test_subdir_conf}
# rsyslog configuration file

#### RULES ####

*.*     ${RSYSLOG_TEST_LOGS[2]}
EOF

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

include(file="${RSYSLOG_TEST_DIR}/*/*.conf" mode="optional")
include(file="${RSYSLOG_TEST_DIR}/*.conf" mode="optional")
include(file="${RSYSLOG_TEST_DIR}" mode="optional")

\$IncludeConfig ${RSYSLOG_TEST_DIR}/*/*.conf
\$IncludeConfig ${RSYSLOG_TEST_DIR}/*.conf
\$IncludeConfig ${RSYSLOG_TEST_DIR}

EOF
