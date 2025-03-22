#!/bin/bash
# platform = multi_platform_all

sed -i 's/^\s*KexAlgorithms\s/# &/i' /etc/ssh/sshd_config
