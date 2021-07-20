# platform = multi_platform_sle,Red Hat Enterprise Linux 8,multi_platform_fedora

DIRS="/lib /lib64 /usr/lib /usr/lib64"
for dirPath in $DIRS; do
	find "$dirPath" -type d -exec chgrp root '{}' \;
done
