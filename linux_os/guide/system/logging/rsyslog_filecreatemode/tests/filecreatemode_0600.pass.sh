#!/bin/bash
# packages = rsyslog

sed -i '/^\s*$FileCreateMode/d' /etc/rsyslog.conf /etc/rsyslog.d/*
echo '$FileCreateMode 0600' > /etc/rsyslog.d/99-rsyslog_filecreatemode.conf
