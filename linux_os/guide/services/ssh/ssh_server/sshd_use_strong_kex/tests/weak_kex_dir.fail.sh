#!/bin/bash
{{% if sshd_distributed_config == "false" %}}
# platform = Not Applicable (sshd_distributed_config=false)
{{% else %}}
# platform = multi_platform_all
{{% endif %}}
# variables = sshd_strong_kex=curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group14-256

sed -i '/^\s*KexAlgorithms\s/Id' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
echo "KexAlgorithms diffie-hellman-group-exchange-sha1" >> /etc/ssh/sshd_config.d/00-test.conf
