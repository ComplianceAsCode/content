#!/bin/bash
# profiles = profile_not_found
# remediation = bash

yum install -y audit

sed -i "/^flush[[:space:]]*=/d" /etc/audit/auditd.conf
