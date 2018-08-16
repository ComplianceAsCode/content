# platform = Red Hat Enterprise Linux 6, Red Hat Enterprise Linux 7
DIRS="/lib /lib64 /usr/lib /usr/lib64"
for dirPath in $DIRS; do
	find "$dirPath" -perm /022 -type f -exec chmod go-w '{}' \;
done
