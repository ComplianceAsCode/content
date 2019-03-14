# platform = multi_platform_sle

fname=$(mktemp -p /etc/pam.d common-auth-XXXXXXXX)
chown --reference=/etc/pam.d/common-auth "$fname"
chmod --reference=/etc/pam.d/common-auth "$fname"

IFS='
'


# we want to add the pam_pkcs11 module at the beginning of the file, after the first comment
comments_over=0
while read line ; do
    if ! [[ "$line" == \#* ]] && [[ "$comments_over" -eq 0 ]] ; then
        echo 'auth sufficient pam_pkcs11.so'
        comments_over=1
    fi
    printf "%s\n" "$line"
done < /etc/pam.d/common-auth > "$fname"

[[ "$comments_over" -eq 0 ]] && echo 'auth sufficient pam_pkcs11.so' >> "$fname"

mv "$fname" /etc/pam.d/common-auth
