#!/bin/bash
{{% if product in ['ol8','rhel8'] %}}
FILE_PATH='/etc/crypto-policies/back-ends/opensshserver.config'
CONF_PREFIX="CRYPTO_POLICY='-oKexAlgorithms="
KEX_ALGOS="ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512"
CONF_SUFIX="'"
CONF_PREFIX_REGEX="^\s*CRYPTO_POLICY"
{{% elif product in ['ol7','rhel7'] %}}
FILE_PATH='/etc/ssh/sshd_config'
CONF_PREFIX="KexAlgorithms "
KEX_ALGOS="ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256"
CONF_PREFIX_REGEX="^\s*KexAlgorithms"
{{% endif %}}

sed -iE "/${CONF_PREFIX_REGEX}/d" "${FILE_PATH}"

CONF="${CONF_PREFIX}${KEX_ALGOS}${CONF_SUFIX}"
