# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_ol,multi_platform_rhv,multi_platform_sle,multi_platform_wrlinux
awk -F: '$3 == 0 && $1 != "root" { print $1 }' /etc/passwd | xargs passwd -l
