# platform = Red Hat Enterprise Linux 9,Red Hat Enterprise Linux 10
# packages = grub2,grubby

# Ensure the kernel command line for each installed kernel in the bootloader
grubby --update-kernel=ALL --remove-args="{{{ ARG_NAME }}}"

mkdir -p /boot/loader/entries
echo "I am an invalid boot entry, but nobody should care, because I am rescue" > /boot/loader/entries/trololol-rescue.conf
