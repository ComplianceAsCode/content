# platform = multi_platform_sle,multi_platform_ubuntu,multi_platform_rhel
DIRS="/lib /lib64"
for dirPath in $DIRS; do
	mkdir -p "$dirPath/testme" && chmod 777  "$dirPath/testme"
done
