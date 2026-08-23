# platform = multi_platform_ubuntu

ssh_approved_ciphers="aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes128-ctr"
{{% set sshc_cipher_list_config = ssh_client_config_dir ~ "/00-cipher-list.conf" %}}

main_config="{{{ ssh_client_main_config_file }}}"
include_directory="{{{ ssh_client_config_dir }}}"
cipher_list_config="$include_directory/00-cipher-list.conf"

sed -i '/^\s*[Cc]iphers.*/d' "$main_config" "$include_directory"/*.conf || true

if ! grep -qE '^[Hh]ost\s+\*$' "$cipher_list_config"; then
  echo 'Host *' >> "$cipher_list_config"
fi

{{{ set_config_file(path=sshc_cipher_list_config, parameter="Ciphers", value='$ssh_approved_ciphers', create=true, insert_before="", insert_after="^Host\s+\*$", insensitive=false, separator=" ", separator_regex="\s\+", prefix_regex="^\s*", rule_id=rule_id) }}}
