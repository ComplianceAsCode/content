# platform = multi_platform_all
# reboot = true
# strategy = disable
# complexity = low
# disruption = medium

# Comment out any occurrences of kernel.core_pattern from /etc/sysctl.d/*.conf files
for f in /etc/sysctl.d/*.conf /run/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf; do

  # skip systemd-sysctl symlink (/etc/sysctl.d/99-sysctl.conf -> /etc/sysctl.conf)
  if [[ "$(readlink -f "$f")" == "/etc/sysctl.conf" ]]; then continue; fi

  matching_list=$(grep -P '^(?!#).*[\s]*kernel.core_pattern.*$' $f | uniq )
  if ! test -z "$matching_list"; then
    while IFS= read -r entry; do
      escaped_entry=$(sed -e 's|/|\\/|g' <<< "$entry")
      # comment out "kernel.core_pattern" matches to preserve user data
      sed -i --follow-symlinks "s/^${escaped_entry}$/# &/g" $f
    done <<< "$matching_list"
  fi
done

#
# Set sysctl config file which to save the desired value
#

SYSCONFIG_FILE='/etc/sysctl.d/kernel_core_pattern.conf'

#
# Set runtime for kernel.core_pattern
#
if {{{ bash_not_bootc_build() }}} ; then
    /sbin/sysctl -q -n -w kernel.core_pattern=""
fi

#
# If kernel.core_pattern present in /etc/sysctl.conf, change value to empty
#	else, add "kernel.core_pattern =" to /etc/sysctl.conf
#

sed -i --follow-symlinks "/^kernel.core_pattern/d" /etc/sysctl.conf

{{{ bash_replace_or_append('${SYSCONFIG_FILE}', '^kernel.core_pattern', '', cce_identifiers=cce_identifiers) }}}
