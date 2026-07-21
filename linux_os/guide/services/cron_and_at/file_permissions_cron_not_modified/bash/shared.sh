# platform = multi_platform_rhel
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

rpm --setugids cronie crontabs
rpm --setperms cronie crontabs
