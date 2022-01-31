# platform = multi_platform_sle,multi_platform_rhel,multi_platform_fedora

DIRS="/lib /lib64 /usr/lib /usr/lib64"
for dirPath in $DIRS; do
	mkdir -p "$dirPath/testme/test2" && chgrp nobody "$dirPath/testme/test2"
done
