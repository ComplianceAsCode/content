# platform = Ubuntu 24.04
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

if id "syslog" >/dev/null 2>&1; then
    username="syslog"
else
    username="root"
fi

find -L /var/log/ -maxdepth 1 -name '*' ! -name '*apt/*' ! -name 'auth.log' ! -name '*[bw]tmp' ! -name '*cloud-init' ! -name '*gdm' ! -name '*.journal' ! -name '*lastlog' ! -name '*localmessages' ! -name '*messages' ! -name 'secure' ! -name '*sssd|*SSSD' ! -name 'syslog' ! -name '*waagent'  -regextype posix-extended -regex '.*' -exec chown $username {} \;
