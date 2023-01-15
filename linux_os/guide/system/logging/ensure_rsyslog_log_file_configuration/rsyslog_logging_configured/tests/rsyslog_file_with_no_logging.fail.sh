#!/bin/bash
# platform = multi_platform_sle

# Check rsyslog.conf with no includes and no loggging facility/priority configured

source $SHARED/rsyslog_log_utils.sh
cat << EOF > ${RSYSLOG_CONF}
# rsyslog configuration file

#### RULES ####

EOF
