#!/bin/bash
# packages = audit

useradd testuser_123

mkdir -p "/var/log/audit"
chown testuser_123 "/var/log/audit"
