#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_sle

# Check rsyslog.conf with log file permissions 0600 from rules and
# log file permissions 0600 from $IncludeConfig passes.

source $SHARED/rsyslog_log_utils.sh

PERMS=0600

# setup test data
create_rsyslog_test_logs 5

# setup test log files and permissions
chmod $PERMS ${RSYSLOG_TEST_LOGS[0]}
chmod $PERMS ${RSYSLOG_TEST_LOGS[1]}
chmod $PERMS ${RSYSLOG_TEST_LOGS[2]}
chmod $PERMS ${RSYSLOG_TEST_LOGS[3]}
chmod $PERMS ${RSYSLOG_TEST_LOGS[4]}

# create test configuration files
conf_subdir=${RSYSLOG_TEST_DIR}/subdir
conf_hiddir=${RSYSLOG_TEST_DIR}/.hiddir
mkdir ${conf_subdir}
mkdir ${conf_hiddir}

test_conf_in_subdir=${conf_subdir}/in_subdir.conf
test_conf_name_bak=${RSYSLOG_TEST_DIR}/name.bak

test_conf_in_hiddir=${conf_hiddir}/in_hiddir.conf
test_conf_dot_name=${RSYSLOG_TEST_DIR}/.name.conf

cat << EOF > ${test_conf_in_subdir}
# rsyslog configuration file

#### RULES ####

*.*     ${RSYSLOG_TEST_LOGS[1]}
EOF

cat << EOF > ${test_conf_name_bak}
# rsyslog configuration file

#### RULES ####

*.*     ${RSYSLOG_TEST_LOGS[2]}
EOF

cat << EOF > ${test_conf_in_hiddir}
# rsyslog configuration file
# not used

#### RULES ####

*.*     ${RSYSLOG_TEST_LOGS[3]}
EOF

cat << EOF > ${test_conf_dot_name}
# rsyslog configuration file
# not used

#### RULES ####

*.*     ${RSYSLOG_TEST_LOGS[4]}
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
