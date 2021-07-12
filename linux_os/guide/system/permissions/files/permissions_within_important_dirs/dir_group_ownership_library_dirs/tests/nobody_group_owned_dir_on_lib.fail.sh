# platform = multi_platform_sle,Red Hat Enterprise Linux 8,multi_platform_fedora

DIRS="/lib /lib64"
for dirPath in $DIRS; do
	mkdir -p "$dirPath/testme" && chown root:nogroup "$dirPath/testme"
done
