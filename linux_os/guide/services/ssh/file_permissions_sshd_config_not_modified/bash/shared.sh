# platform = multi_platform_rhel
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

rpm --setugids openssh-server
rpm --setperms openssh-server
