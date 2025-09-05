# platform = Oracle Linux 7,multi_platform_sle,multi_platform_slmicro,multi_platform_ubuntu

{{%- if 'ubuntu' in product %}}
{{{ bash_instantiate_variables('sshd_approved_ciphers') }}}
{{{ bash_sshd_remediation(parameter="Ciphers", value="$sshd_approved_ciphers", config_is_distributed=sshd_distributed_config) }}}
{{%- else %}}
if grep -q -P '^\s*[Cc]iphers\s+' /etc/ssh/sshd_config; then
  sed -i 's/^\s*[Cc]iphers.*/Ciphers aes256-ctr,aes192-ctr,aes128-ctr/' /etc/ssh/sshd_config
else
  echo "Ciphers aes256-ctr,aes192-ctr,aes128-ctr" >> /etc/ssh/sshd_config
fi
{{%- endif %}}
