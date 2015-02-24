find /etc /bin /usr/bin /usr/lbin /usr/usb /sbin /usr/sbin -follow -gid +499 2>/dev/null | xargs chown :root
