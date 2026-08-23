# platform = multi_platform_ubuntu
# reboot = false
# strategy = configure
# complexity = low
# disruption = low

# see https://workbench.cisecurity.org/benchmarks/18959/tickets/23964
# regarding sssd and gdm exclusions

declare -A valid_shells
while read -r line; do
    [[ "$line" == /* ]] && valid_shells["$line"]=1
done < /etc/shells

declare -A users_with_valid_shells
while IFS=: read -r user _ _ _ _ _ shell; do
    if [[ ${valid_shells["$shell"]} == 1 ]]; then
        users_with_valid_shells["$user"]=1
    fi
done < /etc/passwd

find -P /var/log/ -type f -regextype posix-extended \
    ! -group root ! -group adm  \
    ! -name 'gdm' ! -name 'gdm3' \
    ! -name 'sssd' ! -name 'SSSD' \
    ! -name 'auth.log' \
    ! -name 'messages' \
    ! -name 'syslog' \
    ! -path '/var/log/apt/*' \
    ! -path '/var/log/landscape/*' \
    ! -path '/var/log/gdm/*' \
    ! -path '/var/log/gdm3/*' \
    ! -path '/var/log/sssd/*' \
    ! -path '/var/log/[bw]tmp*' \
    ! -path '/var/log/cloud-init.log*' \
    ! -regex '.*\.journal[~]?' \
    ! -regex '.*/lastlog(\.[^\/]+)?$' \
    ! -regex '.*/localmessages(.*)' \
    ! -regex '.*/secure(.*)' \
    ! -regex '.*/waagent.log(.*)' \
    -print0 | while IFS= read -r -d '' log_file
    do
        # Set to root if owned by a user with a valid shell
        user=$(stat -c "%U" "$log_file")
        if [[ "${users_with_valid_shells["$user"]}" == "1" ]]; then
            chgrp --no-dereference root "$log_file"
        fi
    done
