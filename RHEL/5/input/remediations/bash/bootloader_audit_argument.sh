if [ $(grep -v '#' /boot/grub/grub.conf | grep kernel | grep -c audit=) = 0 ]; then
	sed -i '/^[ |\t]*kernel/s/$/ audit=1/' /boot/grub/grub.conf
else
	sed -i '/^[ |\t]*kernel/s/audit=./audit=1/' /boot/grub/grub.conf
fi
