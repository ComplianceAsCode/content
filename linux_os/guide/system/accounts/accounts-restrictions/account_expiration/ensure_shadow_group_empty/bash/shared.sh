# platform = multi_platform_sle,multi_platform_ubuntu

grep '^shadow:[^:]*:[^:]*:[^:]+' /etc/group
awk -F: '($4 == "<shadow-gid>") { print }' /etc/passwd
