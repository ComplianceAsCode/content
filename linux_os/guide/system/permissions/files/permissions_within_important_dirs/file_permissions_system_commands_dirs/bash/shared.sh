# platform = multi_platform_sle

DIRS="/bin /sbin /usr/bin usr/sbin /usr/local/bin /usr/local/sbin"
for dirPath in $DIRS; do
	find -L "$dirPath" -perm /022 -type f -exec chmod go-w '{}' \;
done
