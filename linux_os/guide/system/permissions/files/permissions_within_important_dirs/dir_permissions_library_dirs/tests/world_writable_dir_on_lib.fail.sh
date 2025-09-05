# platform = multi_platform_sle
DIRS="/lib /lib64"
for dirPath in $DIRS; do
	mkdir -p "$dirPath/testme" && chmod 777  "$dirPath/testme"
done
