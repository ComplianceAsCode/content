# platform = multi_platform_ol,multi_platform_rhel,multi_platform_sle
groupadd nogroup
DIRS="/lib /lib64"
for dirPath in $DIRS; do
	mkdir -p "$dirPath/testme" && chown nobody:nogroup "$dirPath/testme"
done
