#!/bin/bash
# platform = Red Hat Enterprise Linux 8,multi_platform_fedora,Oracle Linux 8,multi_platform_sle

source $SHARED/rsyslog_log_utils.sh

PERMS=0600

# setup test data
create_rsyslog_test_logs 2

# setup test log files and permissions
chmod $PERMS ${RSYSLOG_TEST_LOGS[@]}

# create rsyslog.conf configuration file
cat << EOF > $RSYSLOG_CONF
# rsyslog configuration file

#### RULES ####

*.*     ${RSYSLOG_TEST_LOGS[0]}
:syslogtag, isequal, "[CLOUDINIT]" ${RSYSLOG_TEST_LOGS[1]}
EOF

