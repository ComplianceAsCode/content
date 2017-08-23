# platform = Red Hat Enterprise Linux 7, multi_platform_fedora

SYSTEMCONF='/etc/systemd/system.conf'

ln -sf /dev/null /etc/systemd/system/ctrl-alt-del.target
sed -i 's/^#CtrlAltDelBurstAction=.*/CtrlAltDelBurstAction=none/' "$SYSTEMCONF"
