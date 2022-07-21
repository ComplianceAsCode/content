#!/bin/bash
# platform = multi_platform_fedora,Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_sle

. common.sh

create_config_file_with "[ crypto_policy ]

.include /etc/crypto-policies/back-ends/opensslcnf.config
"
