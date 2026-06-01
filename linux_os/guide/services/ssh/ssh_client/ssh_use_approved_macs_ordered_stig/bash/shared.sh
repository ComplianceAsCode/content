# platform = multi_platform_ubuntu

{{{ bash_instantiate_variables("ssh_approved_macs") }}}
{{%- set sshc_mac_list_config = ssh_client_config_dir ~ "/00-mac-list.conf" -%}}

main_config="{{{ ssh_client_main_config_file }}}"
include_directory="{{{ ssh_client_config_dir }}}"
mac_list_config="$include_directory/00-mac-list.conf"

sed -i '/^\s*MACs.*/d' "$main_config" "$include_directory"/*.conf || true

if ! grep -qE '^[Hh]ost\s+\*$' "$mac_list_config"; then
  echo 'Host *' >> "$mac_list_config"
fi

{{{ set_config_file(path=sshc_mac_list_config, parameter="MACs", value='$ssh_approved_macs', create=true, insert_before="", insert_after="^Host\s+\*$", insensitive=false, separator=" ", separator_regex="\s\+", prefix_regex="^\s*", rule_id=rule_id) }}}
