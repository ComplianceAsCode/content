# platform = multi_platform_sle

grep '^shadow:[^:]*:[^:]*:[^:]+' /etc/group
awk -F: '($4 == "<shadow-gid>") { print }' /etc/passwd
