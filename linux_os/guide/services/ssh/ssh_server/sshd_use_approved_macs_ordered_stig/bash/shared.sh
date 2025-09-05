# platform = Oracle Linux 7,multi_platform_sle,multi_platform_ubuntu

{{%- if 'ubuntu' in product %}}
{{{ bash_instantiate_variables('sshd_approved_macs') }}}
{{{ bash_sshd_remediation(parameter="MACs", value="$sshd_approved_macs", config_is_distributed=sshd_distributed_config) }}}
{{%- else %}}
if grep -q -P '^\s*MACs\s+' /etc/ssh/sshd_config; then
  sed -i 's/^\s*MACs.*/MACs hmac-sha2-512,hmac-sha2-256/' /etc/ssh/sshd_config
else
  echo "MACs hmac-sha2-512,hmac-sha2-256" >> /etc/ssh/sshd_config
fi
{{%- endif %}}
