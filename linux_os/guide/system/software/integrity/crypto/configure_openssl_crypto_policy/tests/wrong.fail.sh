#!/bin/bash
# platform = multi_platform_fedora,Red Hat Enterprise Linux 8

. common.sh

create_config_file_with "[ crypto_policy ]

.include /etc/crypto-policies/back-ends/openssl.config
"
