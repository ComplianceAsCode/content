#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_standard

. common.sh

create_config_file_with "[ crypto_policy ]

.include /etc/crypto-policies/back-ends/openssl.config
"
