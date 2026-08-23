# platform = multi_platform_all
# reboot = false
# strategy = disable
# complexity = medium
# disruption = low

if [[ -f /usr/sbin/prelink ]];
then
prelink -ua
fi

{{{ bash_package_remove(package="prelink") }}}
