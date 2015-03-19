find /etc /bin /usr/bin /usr/lbin /usr/usb /sbin /usr/sbin -follow -perm -20 -o -perm -2 2>/dev/null | xargs chmod go-w
