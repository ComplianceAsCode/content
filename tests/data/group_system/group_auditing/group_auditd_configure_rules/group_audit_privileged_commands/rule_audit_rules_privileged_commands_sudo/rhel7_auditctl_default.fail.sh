#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp
# remediation = bash

sed -i "s%^ExecStartPost=.*%ExecStartPost=-/sbin/auditctl%" /usr/lib/systemd/system/auditd.service
