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

find -L /var/log/ -maxdepth 1 ! -user root ! -user syslog -type f -regextype posix-extended -regex '.*waagent.log(.*)' -exec chown $username {} \;
