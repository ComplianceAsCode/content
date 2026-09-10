#!/bin/bash
# platform = multi_platform_ubuntu

useradd testuser_123

mkdir -p /run/log/journal /var/log/journal
mkdir -p /run/log/journal/wrong_owner_dir
chown -R testuser_123 /run/log/journal/wrong_owner_dir
