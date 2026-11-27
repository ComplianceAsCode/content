#!/bin/bash
# platform = multi_platform_ubuntu

useradd testuser_123

mkdir -p /run/log/journal
# Create a dummy journal file owned by a user other than root so the
# recursive file ownership check fails.
touch /run/log/journal/system.journal
chown testuser_123 /run/log/journal/system.journal
