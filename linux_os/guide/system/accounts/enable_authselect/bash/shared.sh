# platform = multi_platform_all

{{{ bash_instantiate_variables("var_authselect_profile") }}}

authselect current

if test "$?" -ne 0; then
    authselect select "$var_authselect_profile"

    if test "$?" -ne 0; then
        if rpm --quiet --verify pam; then
            authselect select --force "$var_authselect_profile"
        else
	        echo "authselect is not used but files from the 'pam' package have been altered, so the authselect configuration won't be forced." >&2
        fi
    fi
fi
