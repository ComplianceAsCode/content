# platform = SUSE Linux Enterprise 15
DIRS="/lib /lib64"
for dirPath in $DIRS; do
	mkdir -p "$dirPath/testme" && chmod 777  "$dirPath/testme"
done
