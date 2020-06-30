# platform = multi_platform_rhel

(cd / && find . -type f -perm -002 -not -path "./selinux/*" -not -path "./proc/*" -not -path "./sys/*" -not -path "./cgroup/*" -exec chmod -v o-w {} +)
