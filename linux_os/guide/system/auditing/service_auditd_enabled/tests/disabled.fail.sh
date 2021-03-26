#!/bin/bash
# packages = audit

systemctl stop auditd
systemctl disable auditd
systemctl mask auditd
