# platform = multi_platform_sle

IFS='
'

for fs in $(df --local --output=target | tail -n +2) ; do
    for f in $(find "$fs" -xdev -type f \( -perm -4000 -o -perm -2000 \) \( -perm -100 -o -perm -10 -o -perm -1 \) ) ; do
        if ! grep -qP -e '^\s*(?:-w |-F path=)'"$f"' (?:-p |-F perm=)(?:xwa|wxa|wax|xaw|axw|awx) (?:-k |-F key=)\w+\s*$' /etc/audit/audit.rules ; then
            printf "\n%s" "-w $f -p xwa -k privilege_function" >> /etc/audit/audit.rules
        fi
        if ! grep -RqP -e '^\s*(?:-w |-F path=)'"$f"' (?:-p |-F perm=)(?:xwa|wxa|wax|xaw|axw|awx) (?:-k |-F key=)\w+\s*$' /etc/audit/rules.d ; then
            printf "\n%s" "-w $f -p xwa -k privilege_function" >> /etc/audit/rules.d/setxid.rules
        fi
    done
done
