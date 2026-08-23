#!/bin/bash
# platform = multi_platform_fedora

cat <<EOF > /etc/default/grub
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL="serial console"
GRUB_SERIAL_COMMAND="serial --speed=115200"
GRUB_CMDLINE_LINUX="nousb audit=1 audit_backlog_limit=8192 slub_debug=P page_poison=1 vsyscall=none crashkernel=auto resume=/dev/mapper/VolGroup-lv_swap rd.lvm.lv=VolGroup/root rd.lvm.lv=VolGroup/lv_swap net.ifnames=0 console=ttyS0,115200"
GRUB_DISABLE_RECOVERY="true"
GRUB_ENABLE_BLSCFG=true
EOF


