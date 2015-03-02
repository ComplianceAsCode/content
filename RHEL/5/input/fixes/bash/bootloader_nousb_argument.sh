USB_KEYBOARD=$(grep 'Product=' /proc/bus/usb/devices 2>/dev/null| egrep -ic '(ps2 to usb adapter|keyboard|kvm|sc reader)')
if [ "${USB_KEYBOARD}" = "0" ]; then
	sed -i '/^[ |\t]*kernel/s/$/ nousb/' /boot/grub/grub.conf
# else
	# A USB keyboard was detected so this fix has been skipped.
fi
