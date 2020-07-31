# platform = multi_platform_all

(cd / && find / -xdev -type f -perm -002 -exec chmod o-w {} \;)
