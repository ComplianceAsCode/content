# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{{ bash_instantiate_variables("var_accounts_user_umask") }}}

readarray -t profile_files < <(find /etc/profile.d/ -type f -name '*.sh' -or -name 'sh.local')

for file in "${profile_files[@]}" /etc/profile; do
  grep -qE '^[^#]*umask' "$file" && sed -i -E "s/^(\s*umask\s*)[0-7]+/\1$var_accounts_user_umask/g" "$file"
done

if ! grep -qrE '^[^#]*umask' /etc/profile*; then
  echo "umask $var_accounts_user_umask" >> /etc/profile
fi
