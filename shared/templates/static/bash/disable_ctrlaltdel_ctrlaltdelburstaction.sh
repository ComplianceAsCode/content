# platform = Red Hat Enterprise Linux 7, multi_platform_fedora

SYSTEMCONF='/etc/systemd/system.conf'

sed -i 's/^#CtrlAltDelBurstAction=.*/CtrlAltDelBurstAction=none/' "$SYSTEMCONF"
