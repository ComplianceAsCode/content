# platform = multi_platform_sle,multi_platform_rhel,multi_platform_fedora

DIRS="/lib /lib64 /usr/lib /usr/lib64"
for dirPath in $DIRS; do
	find "$dirPath" -type d -exec chgrp root '{}' \;
done
