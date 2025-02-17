# platform = Ubuntu 24.04
# reboot = false
# strategy = configure
# complexity = low
# disruption = low
find -L /var/log/ -maxdepth 1 ! -owner root ! -owner syslog -type f -regextype posix-extended -name 'messages' -exec chown syslog {} \;
