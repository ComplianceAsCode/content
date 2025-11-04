#!/bin/bash
# packages = rsyslog
# platform = multi_platform_ol
source setup.sh

rm -rf "$RSYSLOG_D_FOLDER/*.conf"
truncate -s 0 "${RSYSLOG_CONF}"

echo '*.*    /var/log/messages' >> "${RSYSLOG_CONF}"
