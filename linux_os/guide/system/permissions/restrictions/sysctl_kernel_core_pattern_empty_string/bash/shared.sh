# platform = multi_platform_all
# reboot = true
# strategy = disable
# complexity = low
# disruption = medium

# Comment out any occurrences of kernel.core_pattern from /etc/sysctl.d/*.conf files
for f in /etc/sysctl.d/*.conf /run/sysctl.d/*.conf; do

  matching_list=$(grep -P '^(?!#).*[\s]*kernel.core_pattern.*$' $f | uniq )
  if ! test -z "$matching_list"; then
    while IFS= read -r entry; do
      escaped_entry=$(sed -e 's|/|\\/|g' <<< "$entry")
      # comment out "kernel.core_pattern" matches to preserve user data
      sed -i "s/^${escaped_entry}$/# &/g" $f
    done <<< "$matching_list"
  fi
done

#
# Set runtime for kernel.core_pattern
#
/sbin/sysctl -q -n -w kernel.core_pattern=""

#
# If kernel.core_pattern present in /etc/sysctl.conf, change value to empty
#	else, add "kernel.core_pattern =" to /etc/sysctl.conf
#
# Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
# Otherwise, regular sed command will do.
sed_command=('sed' '-i')
if test -L "/etc/sysctl.conf"; then
    sed_command+=('--follow-symlinks')
fi

# Strip any search characters in the key arg so that the key can be replaced without
# adding any search characters to the config file.
stripped_key=$(sed 's/[\^=\$,;+]*//g' <<< "^kernel.core_pattern")

# shellcheck disable=SC2059
printf -v formatted_output "%s=" "$stripped_key"

# If the key exists, change it. Otherwise, add it to the config_file.
# We search for the key string followed by a word boundary (matched by \>),
# so if we search for 'setting', 'setting2' won't match.
if LC_ALL=C grep -q -m 1 -i -e "^kernel.core_pattern\\>" "/etc/sysctl.conf"; then
    escaped_formatted_output=$(sed -e 's|/|\\/|g' <<< "$formatted_output")
    "${sed_command[@]}" "s/^kernel.core_pattern\\>.*/$escaped_formatted_output/gi" "/etc/sysctl.conf"
else
    # \n is precaution for case where file ends without trailing newline

    printf '%s\n' "$formatted_output" >> "/etc/sysctl.conf"
fi
