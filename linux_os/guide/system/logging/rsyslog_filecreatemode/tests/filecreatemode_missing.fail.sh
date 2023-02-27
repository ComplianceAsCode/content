#!/bin/bash
# platform = multi_platform_ubuntu
# packages = rsyslog

sed -i '/^\s*$FileCreateMode/d' /etc/rsyslog.conf /etc/rsyslog.d/*
systemctl restart rsyslog.service
