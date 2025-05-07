#!/bin/bash
# packages = rsyslog

sed -i '/^\s*$FileCreateMode/d' /etc/rsyslog.conf /etc/rsyslog.d/* || true
echo '$FileCreateMode 0601' > /etc/rsyslog.d/00-rsyslog_filecreatemode.conf
