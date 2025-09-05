#!/bin/bash
# packages = rsyslog

systemctl stop rsyslog
systemctl disable rsyslog
systemctl mask rsyslog
