#!/bin/bash
# platform = multi_platform_almalinux

# A repository section without an enabled option is enabled by default.
cat > /etc/yum.repos.d/tuxcare.repo <<'REPO'
[tuxcare-esu]
name=TuxCare Enterprise Support for AlmaLinux 9.2 - ESU
baseurl=https://repo.tuxcare.com/tuxcare/esu/9.2/$basearch/
gpgcheck=1
REPO
