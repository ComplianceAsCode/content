#!/bin/bash
# packages = {{{- ssgts_package("audit") -}}}

systemctl stop auditd
systemctl disable auditd
systemctl mask auditd
