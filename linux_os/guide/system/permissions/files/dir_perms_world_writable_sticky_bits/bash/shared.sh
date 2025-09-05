# platform = Red Hat Virtualization 4,multi_platform_rhel
df --local -P | awk '{if (NR!=1) print $6}' \
| xargs -I '{}' find '{}' -xdev -type d \
\( -perm -0002 -a ! -perm -1000 \) 2>/dev/null \
| xargs chmod a+t
