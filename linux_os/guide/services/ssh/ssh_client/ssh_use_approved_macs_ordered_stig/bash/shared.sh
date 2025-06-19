# platform = multi_platform_ubuntu

{{{ bash_instantiate_variables("ssh_approved_macs") }}}

main_config="/etc/ssh/ssh_config"
include_directory="/etc/ssh/ssh_config.d"

sed -i '/^\s*MACs.*/d' "$main_config" "$include_directory"/*.conf || true

if ! grep -qE '^[Hh]ost\s+\*$' /etc/ssh/ssh_config.d/00-mac-list.conf; then
  echo 'Host *' >> /etc/ssh/ssh_config.d/00-mac-list.conf
fi

{{{ set_config_file(path="/etc/ssh/ssh_config.d/00-mac-list.conf", parameter="MACs", value='$ssh_approved_macs', create=true, insert_before="", insert_after="^Host\s+\*$", insensitive=false, separator=" ", separator_regex="\s\+", prefix_regex="^\s*", rule_id=rule_id) }}}
