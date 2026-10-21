#!/bin/bash
# platform = Red Hat Enterprise Linux 10

. common.sh

create_config_file_with "[ crypto_policy ]

.include /etc/crypto-policies/back-ends/opensslcnf.config
"
