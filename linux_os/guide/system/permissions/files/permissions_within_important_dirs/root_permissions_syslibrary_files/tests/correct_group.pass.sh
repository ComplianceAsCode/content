# platform = multi_platform_sle,Red Hat Enterprise Linux 8,multi_platform_fedora

for SYSLIBDIRS in /lib /lib64 /usr/lib /usr/lib64
do
    if [[ -d $SYSLIBDIRS  ]]
    then
        find $SYSLIBDIRS ! -group root -type f -exec chgrp root '{}' \;
    fi
done
