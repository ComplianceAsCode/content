# platform = multi_platform_ubuntu

chmod 0755 /var/log/

if grep -q "^z \/var\/log " /usr/lib/tmpfiles.d/00rsyslog.conf; then
    sed -i --follow-symlinks "s/\(^z[[:space:]]\+\/var\/log[[:space:]]\+\)\(\([[:digit:]]\+\)[^ $]*\)/\10755/" /usr/lib/tmpfiles.d/00rsyslog.conf
fi
