# platform = multi_platform_ol,multi_platform_sle,multi_platform_ubuntu

readarray -t users_with_empty_pass < <(sudo awk -F: '!$2 {print $1}' /etc/shadow)

for user_with_empty_pass in "${users_with_empty_pass[@]}"
do
    passwd -l $user_with_empty_pass
done
