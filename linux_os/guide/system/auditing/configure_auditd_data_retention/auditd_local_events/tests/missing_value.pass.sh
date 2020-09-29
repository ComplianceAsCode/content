#!/bin/bash
touch "/etc/audit/auditd.conf"
sed -i "/local_events/d" "/etc/audit/auditd.conf"
