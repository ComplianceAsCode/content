# platform = multi_platform_wrlinux,Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_ol,multi_platform_rhv,multi_platform_sle
awk -F: '$3 == 0 && $1 != "root" { print $1 }' /etc/passwd | xargs --max-lines=1 passwd -l
