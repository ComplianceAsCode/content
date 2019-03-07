# platform = multi_platform_sle

IFS='
'

set -x

for fs in $(df --local --output=target | tail -n +2) ; do
    for f in $(find "$fs" -xdev -type f \( -perm -4000 -o -perm -2000 \) \( -perm -100 -o -perm -10 -o -perm -1 \) ) ; do
        if ! grep -qF -e "-w $f -p xwa -k privilege_function" /etc/audit/audit.rules ; then
            printf "\n%s" "-w $f -p xwa -k privilege_function" >> /etc/audit/audit.rules
        fi
    done
done
