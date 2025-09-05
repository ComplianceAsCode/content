# platform = multi_platform_ol,multi_platform_rhel,multi_platform_sle
DIRS="/lib /lib64 /usr/lib /usr/lib64"
for dirPath in $DIRS; do
	find "$dirPath" -type d -exec chown root '{}' \;
done
