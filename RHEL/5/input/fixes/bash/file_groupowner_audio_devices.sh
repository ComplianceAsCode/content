chown :root /dev/audio* /dev/snd/*
if [[ "`uname -r`" = "2.6.9"* ]]; then
	sed -i 's/\(^audio\*:[a-z]*:\)[a-z]*:/\1sys:/' /etc/udev/permissions.d/50-udev.permissions
elif [[ "`uname -r`" = "2.6.18"* ]]; then
	sed -i '/^<console>  [0-9]* <sound>/s/<sound>.*/<sound>      0600 root.root/' /etc/security/console.perms.d/50-default.perms
fi
