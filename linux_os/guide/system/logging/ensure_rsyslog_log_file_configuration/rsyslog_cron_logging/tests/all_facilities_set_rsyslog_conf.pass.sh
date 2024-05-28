#!/bin/bash
# packages = rsyslog
# platform = Oracle Linux 7,Oracle Linux 8

. set_cron_logging.sh

RSYSLOG_CONF='/etc/rsyslog.conf'
RSYSLOG_D_FOLDER='/etc/rsyslog.d'
RSYSLOG_D_FILES=("${RSYSLOG_D_FOLDER}"/*)

mkdir -p "${RSYSLOG_D_FOLDER}"
rm -rf "${RSYSLOG_D_FILES[@]}"
truncate -s 0 "${RSYSLOG_CONF}"

echo '*.*    /var/log/messages' >> "${RSYSLOG_CONF}"
