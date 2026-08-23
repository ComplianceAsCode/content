#!/bin/bash
# packages = rsyslog

sed -i '/^\s*$FileCreateMode/d' /etc/rsyslog.conf /etc/rsyslog.d/* || true
echo '$FileCreateMode 0640' > /etc/rsyslog.d/00-rsyslog_filecreatemode.conf
echo '$FileCreateMode 0640' >> /etc/rsyslog.conf
