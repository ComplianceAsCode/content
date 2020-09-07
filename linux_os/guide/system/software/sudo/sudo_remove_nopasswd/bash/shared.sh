# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

for f in $( ls /etc/sudoers /etc/sudoers.d/* 2> /dev/null ) ; do
  nopasswd_list=$(grep -P '^(?!#).*[\s]+NOPASSWD[\s]*\:.*$' $f | uniq )
  if ! test -z "$nopasswd_list"; then 
    while IFS= read -r nopasswd_entry; do
      # comment out "NOPASSWD:" matches to preserve user data
      sed -i "s/^${nopasswd_entry}$/# &/g" $f
    done <<< "$nopasswd_list"

    /usr/sbin/visudo -cf $f &> /dev/null || echo "Fail to validate $f with visudo"
  fi
done
