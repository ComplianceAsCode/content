# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{{ bash_instantiate_variables("var_user_initialization_files_regex") }}}

readarray -t interactive_users < <(awk -F: '$3==0 || $3>={{{ uid_min }}}   {print $1}' /etc/passwd)
readarray -t interactive_users_home < <(awk -F: '$3==0 || $3>={{{ uid_min }}}   {print $6}' /etc/passwd)
readarray -t interactive_users_shell < <(awk -F: '$3==0 || $3>={{{ uid_min }}}   {print $7}' /etc/passwd)

USERS_IGNORED_REGEX='nobody|nfsnobody'

for (( i=0; i<"${#interactive_users[@]}"; i++ )); do
    if ! grep -qP "$USERS_IGNORED_REGEX" <<< "${interactive_users[$i]}" && \
        [ "${interactive_users_shell[$i]}" != "/sbin/nologin" ]; then

        readarray -t init_files < <(find "${interactive_users_home[$i]}" -maxdepth 1 \
            -exec basename {} \; | grep -P "$var_user_initialization_files_regex")
        for file in "${init_files[@]}"; do
            chmod u-s,g-wxs,o= "${interactive_users_home[$i]}/$file"
        done
    fi
done

