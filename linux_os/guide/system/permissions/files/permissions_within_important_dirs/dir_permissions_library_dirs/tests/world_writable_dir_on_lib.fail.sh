# platform = multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_ubuntu
DIRS="/lib /lib64"
for dirPath in $DIRS; do
	mkdir -p "$dirPath/testme" && chmod 777  "$dirPath/testme"
done
