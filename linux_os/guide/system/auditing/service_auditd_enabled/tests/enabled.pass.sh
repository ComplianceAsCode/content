#!/bin/bash
# packages = {{{- ssgts_package("audit") -}}}

systemctl start auditd
systemctl enable auditd
