#!/bin/bash
# packages = rsyslog

sed -i '/^\s*$FileCreateMode/d' /etc/rsyslog.conf /etc/rsyslog.d/* || true
