#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_sle,multi_platform_almalinux

# Regression test for: bash remediation correctly processes all log file paths from a
# real-world default RainerScript rsyslog.conf with multiple action(type="omfile" ...)
# entries, including entries with extra attributes (e.g. sync="on") after the File= field.
#
# Previously, two bugs caused remediation to silently do nothing:
# 1. grep -iozP stored NUL-separated matches in a bash variable, stripping NULs and
#    corrupting multi-match output (fixed by piping through tr '\0' '\n').
# 2. The extracted paths were appended as a single newline-joined string instead of
#    individual array elements (fixed by using readarray).

# Declare variables used for the tests and define the create_rsyslog_test_logs function
source $SHARED/rsyslog_log_utils.sh

{{% if ATTRIBUTE == "owner" %}}
CHATTR="chown"
ATTR_INCORRECT_VALUE="cac_testuser"
useradd $ATTR_INCORRECT_VALUE
{{% elif ATTRIBUTE == "groupowner" %}}
CHATTR="chgrp"
ATTR_INCORRECT_VALUE="cac_testgroup"
groupadd $ATTR_INCORRECT_VALUE
{{% else %}}
CHATTR="chmod"
ATTR_INCORRECT_VALUE="0644"
{{% endif %}}

# Create 6 test log files mirroring a default RHEL10/CS10 rsyslog setup
create_rsyslog_test_logs 6

# Set all files to the incorrect attribute value
$CHATTR $ATTR_INCORRECT_VALUE ${RSYSLOG_TEST_LOGS[0]}
$CHATTR $ATTR_INCORRECT_VALUE ${RSYSLOG_TEST_LOGS[1]}
$CHATTR $ATTR_INCORRECT_VALUE ${RSYSLOG_TEST_LOGS[2]}
$CHATTR $ATTR_INCORRECT_VALUE ${RSYSLOG_TEST_LOGS[3]}
$CHATTR $ATTR_INCORRECT_VALUE ${RSYSLOG_TEST_LOGS[4]}
$CHATTR $ATTR_INCORRECT_VALUE ${RSYSLOG_TEST_LOGS[5]}

# Write a realistic default rsyslog.conf using RainerScript action(type="omfile" ...)
# syntax for all log rules. Note: one entry has sync="on" after the File= field to
# exercise the multiline/multi-attribute parsing path.
cat << EOF > $RSYSLOG_CONF
# rsyslog configuration file

#### GLOBAL DIRECTIVES ####
global(workDirectory="/var/lib/rsyslog")

#### MODULES ####
module(load="builtin:omfile" Template="RSYSLOG_TraditionalFileFormat")

module(load="imuxsock"
       SysSock.Use="off")
module(load="imjournal"
       UsePid="system"
       FileCreateMode="0644"
       StateFile="imjournal.state")

# Include all config files in /etc/rsyslog.d/
include(file="/etc/rsyslog.d/*.conf" mode="optional")

#### RULES ####
*.info;mail.none;authpriv.none;cron.none action(type="omfile" file="${RSYSLOG_TEST_LOGS[0]}")
authpriv.*                               action(type="omfile" file="${RSYSLOG_TEST_LOGS[1]}")
mail.*                                   action(type="omfile" file="${RSYSLOG_TEST_LOGS[2]}" sync="on")
cron.*                                   action(type="omfile" file="${RSYSLOG_TEST_LOGS[3]}")
uucp,news.crit                           action(type="omfile" file="${RSYSLOG_TEST_LOGS[4]}")
local7.*                                 action(type="omfile" file="${RSYSLOG_TEST_LOGS[5]}")
EOF
