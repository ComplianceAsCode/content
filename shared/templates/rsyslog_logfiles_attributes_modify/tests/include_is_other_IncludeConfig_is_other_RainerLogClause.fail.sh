#!/bin/bash
# platform = Red Hat Enterprise Linux 8,multi_platform_fedora,Oracle Linux 8,multi_platform_sle

# Check rsyslog.conf with root user log from rules and
# root user log from include() passes.

source $SHARED/rsyslog_log_utils.sh

{{% if ATTRIBUTE == "owner" %}}
CHATTR="chown"
{{% else %}}
CHATTR="chgrp"
{{% endif %}}

USER_TEST=testssg

USER=root

# setup test data
create_rsyslog_test_logs 3

# setup test log files ownership
$CHATTR $USER_TEST ${RSYSLOG_TEST_LOGS[0]}
$CHATTR $USER_TEST ${RSYSLOG_TEST_LOGS[1]}
$CHATTR $USER_TEST ${RSYSLOG_TEST_LOGS[2]}

# create test configuration file
test_conf=${RSYSLOG_TEST_DIR}/test1.conf
cat << EOF > ${test_conf}
# rsyslog configuration file

#### RULES ####

*.*     ${RSYSLOG_TEST_LOGS[1]}
EOF

# create test2 configuration file
test_conf2=${RSYSLOG_TEST_DIR}/test2.conf
{{% if ATTRIBUTE == "owner" %}}
cat << EOF > ${test_conf2}
# rsyslog configuration file

#### RULES ####


*.*     action(type="omfile" FileCreateMode="0640" fileOwner="$USER_TEST" fileGroup="root" File="${RSYSLOG_TEST_LOGS[2]}")
EOF
{{% else %}}
cat << EOF > ${test_conf2}
# rsyslog configuration file

#### RULES ####


*.*     action(type="omfile" FileCreateMode="0640" fileOwner="root" fileGroup="$USER_TEST" File="${RSYSLOG_TEST_LOGS[2]}")
EOF
{{% endif %}}

# create rsyslog.conf configuration file
cat << EOF > $RSYSLOG_CONF
# rsyslog configuration file

#### RULES ####

*.*     ${RSYSLOG_TEST_LOGS[0]}

#### MODULES ####

include(file="${test_conf}")

\$IncludeConfig ${test_conf2}
EOF
