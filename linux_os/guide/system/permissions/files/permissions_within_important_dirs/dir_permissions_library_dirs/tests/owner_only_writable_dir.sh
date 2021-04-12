# platform = multi_platform_sle
DIRS="/lib /lib64 /usr/lib /usr/lib64"
for dirPath in $DIRS; do
	mkdir -p "$dirPath/testme" && chmod 700  "$dirPath/testme"
done
