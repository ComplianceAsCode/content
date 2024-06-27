# platform = Oracle Linux 7,multi_platform_sle,multi_platform_ubuntu

KEX_ALGOS="ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,\
diffie-hellman-group-exchange-sha256"

{{%- if 'ubuntu' in product %}}
{{{ bash_sshd_remediation(parameter="KexAlgorithms", value="$KEX_ALGOS", config_is_distributed=sshd_distributed_config) }}}
{{%- else %}}

if grep -q -P '^\s*KexAlgorithms\s+' /etc/ssh/sshd_config; then
  sed -i "s/^\s*KexAlgorithms.*/KexAlgorithms ${KEX_ALGOS}/" /etc/ssh/sshd_config
else
  echo "KexAlgorithms ${KEX_ALGOS}" >> /etc/ssh/sshd_config
fi
{{%- endif %}}
