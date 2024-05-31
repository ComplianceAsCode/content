#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_sle

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

# create one test log file
create_rsyslog_test_logs 1

# setup test log file property
$CHATTR $ATTR_VALUE ${RSYSLOG_TEST_LOGS[0]}

# ignore check and remediation for files which are not used for logs
NO_LOG_FILE="/etc/pki/tls/certs/ca-bundle.crt"
touch $NO_LOG_FILE
$CHATTR $ATTR_INCORRECT_VALUE $NO_LOG_FILE

# example of configuration file including three filepaths but only one specifies
# a log file, in the last rule.
cat << EOF > $RSYSLOG_CONF
# rsyslog configuration file
global(workDirectory="/var/spool/rsyslog" net.ipprotocol="ipv4-only" DefaultNetstreamDriver="gtls" DefaultNetstreamDriverCAFile="${NO_LOG_FILE}")

#### RULES ####
# Should only check value of "File" and not other variations such as "DefaultNetstreamDriverCAFile".
*.*     action(type="omfile" FileCreateMode="0640" fileOwner="root" fileGroup="hoiadm" DefaultNetstreamDriverCAFile="${NO_LOG_FILE}")

# Here is a valid entry defining a log file.
*.*     action(type="omfile" FileCreateMode="0640" fileOwner="root" fileGroup="hoiadm" File="${RSYSLOG_TEST_LOGS[0]}")

EOF
