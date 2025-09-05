# platform = multi_platform_sle,multi_platform_rhel
DIRS="/lib /lib64 /usr/lib /usr/lib64"
for dirPath in $DIRS; do
	find "$dirPath" -type d -exec chown root '{}' \;
done
