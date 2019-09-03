#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss
# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol

# Check rsyslog.conf with root group-owner log from rules and
# root group-owner log from $IncludeConfig passes.

source $SHARED/rsyslog_log_utils.sh

GROUP=root

# setup test data
create_rsyslog_test_logs 2

# setup test log files ownership
chgrp $GROUP ${RSYSLOG_TEST_LOGS[0]}
chgrp $GROUP ${RSYSLOG_TEST_LOGS[1]}

# create test configuration file
test_conf=${RSYSLOG_TEST_DIR}/test1.conf
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

\$IncludeConfig ${test_conf}
EOF
