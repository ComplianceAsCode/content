find /etc /bin /usr/bin /usr/lbin /usr/usb /sbin /usr/sbin -follow -uid +499 2>/dev/null | xargs chown root
