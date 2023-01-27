#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_sle

# Declare variables used for the tests and define the create_rsyslog_test_logs function
source $SHARED/rsyslog_log_utils.sh

{{% if ATTRIBUTE == "owner" %}}
ADDCOMMAND="useradd"
CHATTR="chown"
{{% else %}}
ADDCOMMAND="groupadd"
CHATTR="chgrp"
{{% endif %}}

ATTR_VALUE=root
ATTR_VALUE_INCORRECT=testssg
$ADDCOMMAND $ATTR_VALUE_INCORRECT

# create three test log file
create_rsyslog_test_logs 2

# setup test log file property
$CHATTR $ATTR_VALUE_INCORRECT ${RSYSLOG_TEST_LOGS[0]}
$CHATTR $ATTR_VALUE ${RSYSLOG_TEST_LOGS[1]}

# add rules with both syntax for different test log files
cat << EOF > $RSYSLOG_CONF
# rsyslog configuration file

#### RULES ####
*.*     ${RSYSLOG_TEST_LOGS[0]}
*.*     action(type="omfile" FileCreateMode="0640" fileOwner="root" fileGroup="hoiadm" File="${RSYSLOG_TEST_LOGS[1]}")

EOF
