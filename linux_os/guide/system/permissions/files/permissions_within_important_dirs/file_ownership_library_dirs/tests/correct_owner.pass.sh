# platform = multi_platform_sle,Red Hat Enterprise Linux 8,multi_platform_fedora,multi_platform_ubuntu

for SYSLIBDIRS in /lib /lib64 /usr/lib /usr/lib64
do
    if [[ -d $SYSLIBDIRS  ]]
    then
        find $SYSLIBDIRS ! -user root -type f -exec chown root '{}' \;
    fi
done
