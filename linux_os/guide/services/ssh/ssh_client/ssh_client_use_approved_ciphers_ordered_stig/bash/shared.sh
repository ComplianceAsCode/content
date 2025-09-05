# platform = multi_platform_ubuntu

ssh_approved_ciphers="aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes128-ctr"

main_config="/etc/ssh/ssh_config"
include_directory="/etc/ssh/ssh_config.d"

sed -i '/^\s*[Cc]iphers.*/d' "$main_config" "$include_directory"/*.conf || true

if ! grep -qE '^[Hh]ost\s+\*$' /etc/ssh/ssh_config.d/00-cipher-list.conf; then
  echo 'Host *' >> /etc/ssh/ssh_config.d/00-cipher-list.conf
fi

{{{ set_config_file(path="/etc/ssh/ssh_config.d/00-cipher-list.conf", parameter="Ciphers", value='$ssh_approved_ciphers', create=true, insert_before="", insert_after="^Host\s+\*$", insensitive=false, separator=" ", separator_regex="\s\+", prefix_regex="^\s*", rule_id=rule_id) }}}
