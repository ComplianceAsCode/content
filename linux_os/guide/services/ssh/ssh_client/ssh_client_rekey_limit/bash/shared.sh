# platform = multi_platform_all

{{{ bash_instantiate_variables("var_ssh_client_rekey_limit_size", "var_ssh_client_rekey_limit_time") }}}
{{%- set sshc_rekey_config = ssh_client_config_dir ~ "/02-rekey-limit.conf" -%}}

main_config="{{{ ssh_client_main_config_file }}}"
include_directory="{{{ ssh_client_config_dir }}}"

if grep -q '^[\s]*RekeyLimit.*$' "$main_config"; then
  sed -i '/^[\s]*RekeyLimit.*/d' "$main_config"
fi

for file in "$include_directory"/*.conf; do
  if grep -q '^[\s]*RekeyLimit.*$' "$file"; then
    sed -i '/^[\s]*RekeyLimit.*/d' "$file"
  fi
done

{{{ set_config_file(path=sshc_rekey_config, parameter="RekeyLimit", value='$var_ssh_client_rekey_limit_size $var_ssh_client_rekey_limit_time', create=true, insert_before="", insert_after="", insensitive=false, separator=" ", separator_regex="\s\+", prefix_regex="^\s*", rule_id=rule_id) }}}
