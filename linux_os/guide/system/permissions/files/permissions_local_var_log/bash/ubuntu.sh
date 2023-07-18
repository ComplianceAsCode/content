# platform = multi_platform_ubuntu

readarray -t files < <(find /var/log/ -type f)
for file in "${files[@]}"; do
    if basename $file | grep -qE '^.*$'; then
        chmod 0640 $file
    fi
done

if grep -qE "^f \/var\/log\/(btmp|wtmp|lastlog)? " /usr/lib/tmpfiles.d/var.conf; then
    sed -i --follow-symlinks "s/\(^f[[:space:]]\+\/var\/log\/btmp[[:space:]]\+\)\(\([[:digit:]]\+\)[^ $]*\)/\10640/" /usr/lib/tmpfiles.d/var.conf
    sed -i --follow-symlinks "s/\(^f[[:space:]]\+\/var\/log\/wtmp[[:space:]]\+\)\(\([[:digit:]]\+\)[^ $]*\)/\10640/" /usr/lib/tmpfiles.d/var.conf
    sed -i --follow-symlinks "s/\(^f[[:space:]]\+\/var\/log\/lastlog[[:space:]]\+\)\(\([[:digit:]]\+\)[^ $]*\)/\10640/" /usr/lib/tmpfiles.d/var.conf
fi
