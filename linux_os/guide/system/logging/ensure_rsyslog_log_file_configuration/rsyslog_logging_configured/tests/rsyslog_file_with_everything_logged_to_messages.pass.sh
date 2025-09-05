#!/bin/bash
# platform = multi_platform_sle

# Check rsyslog.conf with no includes and all loggging facility/priority configured to go to /var/log/messages

source $SHARED/rsyslog_log_utils.sh
cat << EOF > ${RSYSLOG_CONF}
# rsyslog configuration file

#### RULES ####

*.*       /var/log/messages
EOF
