# platform = Red Hat Enterprise Linux 6
rpm -q prelink &>/dev/null && sed -i '/^PRELINKING/s,yes,no,' /etc/sysconfig/prelink
rpm -q prelink &>/dev/null && prelink -ua
grubby --update-kernel=$(grubby --default-kernel) --args=fips=1
uuid=$(findmnt -no uuid /boot)
[[ -n $uuid ]] && grubby --update-kernel=$(grubby --default-kernel) --args=boot=UUID=${uuid}
dracut -f
