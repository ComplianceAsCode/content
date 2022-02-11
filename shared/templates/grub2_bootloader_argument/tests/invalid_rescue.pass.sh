# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 9
# packages = grub2,grubby

{{{ grub2_bootloader_argument_remediation(ARG_NAME, ARG_NAME_VALUE) }}}

echo "I am an invalid boot entry, but nobody should care, because I am rescue" > /boot/loader/entries/trololol-rescue.conf
