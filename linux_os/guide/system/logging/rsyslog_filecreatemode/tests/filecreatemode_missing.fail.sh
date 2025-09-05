#!/bin/bash
# packages = rsyslog

rm -f /etc/rsyslog.d/*
sed -i '/^\s*$FileCreateMode/d' /etc/rsyslog.conf
