# platform = multi_platform_sle,multi_platform_rhel,multi_platform_fedora,multi_platform_ubuntu

for SYSLIBDIRS in /lib /lib64 /usr/lib /usr/lib64
do
    if [[ -d $SYSLIBDIRS  ]]
    then
        find $SYSLIBDIRS ! -group root -type f -exec chgrp root '{}' \;
    fi
done
