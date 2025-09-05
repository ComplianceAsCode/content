# platform = multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_ubuntu
DIRS="/lib /lib64 /usr/lib /usr/lib64"
for dirPath in $DIRS; do
	find "$dirPath" -perm /022 -type d -exec chmod go-w '{}' \;
done
