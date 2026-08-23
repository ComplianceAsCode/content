#!/bin/bash
# packages = audit

useradd testuser_123

touch "/var/log/audit/audit.log"
chown testuser_123 "/var/log/audit/audit.log"
