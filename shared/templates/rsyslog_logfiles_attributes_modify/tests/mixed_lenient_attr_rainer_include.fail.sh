#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_sle,multi_platform_ubuntu

# Declare variables used for the tests and define the create_rsyslog_test_logs function
source $SHARED/rsyslog_log_utils.sh

{{% if ATTRIBUTE == "owner" %}}
CHATTR="chown"
ATTR_VALUE="root"
ATTR_INCORRECT_VALUE="cac_testuser"
useradd $ATTR_INCORRECT_VALUE
{{% elif ATTRIBUTE == "groupowner" %}}
CHATTR="chgrp"
ATTR_VALUE="root"
ATTR_INCORRECT_VALUE="cac_testgroup"
groupadd $ATTR_INCORRECT_VALUE
{{% else %}}
CHATTR="chmod"
ATTR_VALUE="0640"
ATTR_INCORRECT_VALUE="0666"
{{% endif %}}

# create three test log file
create_rsyslog_test_logs 3

# setup test log file property
$CHATTR $ATTR_VALUE ${RSYSLOG_TEST_LOGS[0]}
$CHATTR $ATTR_VALUE ${RSYSLOG_TEST_LOGS[1]}
$CHATTR $ATTR_INCORRECT_VALUE ${RSYSLOG_TEST_LOGS[2]}

# create first test configuration file with legacy rule for second test log file
test_conf1=${RSYSLOG_TEST_DIR}/legacy.conf
cat << EOF > ${test_conf1}
# rsyslog test configuration file with legacy syntax

#### RULES ####
*.*     ${RSYSLOG_TEST_LOGS[1]}

EOF

# create second test configuration file with RainerScript rule for third test log file
test_conf2=${RSYSLOG_TEST_DIR}/rainerscript.conf
cat << EOF > ${test_conf2}
# rsyslog test configuration file with RainerScript syntax

#### RULES ####
*.*     action(type="omfile" FileCreateMode="0640" fileOwner="root" fileGroup="hoiadm" File="${RSYSLOG_TEST_LOGS[2]}")

EOF

# add rule with first test log file plus two mixed include statement
cat << EOF > $RSYSLOG_CONF
# rsyslog configuration file

#### RULES ####
*.*     ${RSYSLOG_TEST_LOGS[0]}

#### MODULES ####
\$IncludeConfig ${test_conf1}

include(file="${test_conf2}")

EOF
