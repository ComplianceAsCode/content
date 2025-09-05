# platform = multi_platform_sle

for link in $(find /etc/pam.d/ -type l -iname "common-*") ; do
    target=$(readlink -f "$link")
    cp -p --remove-destination "$target" "$link"
done
