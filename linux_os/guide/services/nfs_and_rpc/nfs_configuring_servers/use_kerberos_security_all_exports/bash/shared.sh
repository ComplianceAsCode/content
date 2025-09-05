# platform = multi_platform_all
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

nfs_exports=()
readarray -t nfs_exports < <(grep -E "^/.*[[:space:]]+ .*\(.*\)[[:space:]]*$" /etc/exports | awk '{print $2}')

for nfs_export in "${nfs_exports[@]}"
do
    correct_export=""
    if [ "$(grep -c "sec=" <<<"$nfs_export")" -eq 0 ]; then
        correct_export="$(echo $nfs_export|sed  -e 's/).*$/,sec=krb5\:krb5i\:krb5p)/')"
    else
        correct_export="$(echo $nfs_export|sed  -e 's/sec=[^\,\)]*/sec=krb5\:krb5i\:krb5p/')"
    fi
    sed -i "s|$nfs_export|$correct_export|g" /etc/exports
done
