#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_sle

# Declare variables used for the tests and define the create_rsyslog_test_logs function
source $SHARED/rsyslog_log_utils.sh

{{% if ATTRIBUTE == "owner" %}}
CHATTR="chown"
{{% else %}}
CHATTR="chgrp"
{{% endif %}}
ATTR_VALUE=root

# create one test log file
create_rsyslog_test_logs 1

# setup test log file property
$CHATTR $ATTR_VALUE ${RSYSLOG_TEST_LOGS[0]}

# add rule with test log file
cat << EOF > $RSYSLOG_CONF
# rsyslog configuration file

#### RULES ####
*.*     action(type="omfile" FileCreateMode="0640" fileOwner="root" fileGroup="hoiadm" File="${RSYSLOG_TEST_LOGS[0]}")

EOF
