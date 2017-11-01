# platform = Red Hat Enterprise Linux 7
#
# Disable all enabled services, except for systemd-* getty* and autovt*
#
systemctl list-unit-files | grep enabled | grep -oP '^(?!systemd-)(?!getty)(?!autovt)\S+\.service' | xargs systemctl disable
