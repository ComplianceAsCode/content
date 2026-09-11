# platform = multi_platform_all

{{{ bash_instantiate_variables("var_multiple_time_servers") }}}

config_file="{{{ chrony_conf_path }}}"

has_remote_source=false
if grep -q '^[[:space:]]*\(server\|pool\)[[:space:]]\+[[:graph:]]\+' "$config_file" 2>/dev/null; then
  has_remote_source=true
fi

while [[ "$has_remote_source" == false ]] && read -r directive location _; do
  [[ "$directive" == sourcedir || "$directive" == confdir ]] || continue
  extension='*.conf'
  [[ "$directive" == sourcedir ]] && extension='*.sources'
  while IFS= read -r -d '' include_file; do
    if grep -q '^[[:space:]]*\(server\|pool\)[[:space:]]\+[[:graph:]]\+' "$include_file"; then
      has_remote_source=true
      break
    fi
  done < <(find -L "$location" -maxdepth 1 -type f -name "$extension" -print0 2>/dev/null)
done < "$config_file"

if [[ "$has_remote_source" == false ]]; then
  sourcedir=$(awk '$1 == "sourcedir" { print $2; exit }' "$config_file")
  if [[ -n "$sourcedir" ]]; then
    mkdir -p "$sourcedir"
    config_file="$sourcedir/60-cis.sources"
  fi
  {{{ bash_ensure_there_are_servers_in_ntp_compatible_config_file("$config_file", "$var_multiple_time_servers") | indent(2) }}}
fi
