# platform = Red Hat Virtualization 4,multi_platform_rhel
DIRS="/bin /usr/bin /usr/local/bin /sbin /usr/sbin /usr/local/sbin /usr/libexec"
for dirPath in $DIRS; do
	find "$dirPath" -perm /022 -exec chmod go-w '{}' \;
done
