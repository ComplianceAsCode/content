#!/bin/bash
# platform = multi_platform_almalinux

cat > /etc/yum.repos.d/tuxcare.repo <<'REPO'
[tuxcare-base]
name=TuxCare Enterprise Support for AlmaLinux 9.2 - Base
enabled=1

[tuxcare-esu]
name=TuxCare Enterprise Support for AlmaLinux 9.2 - ESU
baseurl=https://repo.tuxcare.com/tuxcare/esu/9.2/$basearch/
enabled=1
gpgcheck=1
REPO
