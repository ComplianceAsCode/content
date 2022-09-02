# platform = multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_ubuntu
DIRS="/lib /lib64 /usr/lib /usr/lib64"
for dirPath in $DIRS; do
    chmod -R 755 "$dirPath"
	mkdir -p "$dirPath/testme" && chmod 700  "$dirPath/testme"
done
