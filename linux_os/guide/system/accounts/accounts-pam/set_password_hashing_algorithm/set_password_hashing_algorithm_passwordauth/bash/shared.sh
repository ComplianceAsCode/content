# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_rhv,multi_platform_ol

{{{ bash_instantiate_variables("var_password_hashing_algorithm_pam") }}}
PAM_FILE_PATH="/etc/pam.d/password-auth"

{{{ bash_ensure_pam_module_configuration("$PAM_FILE_PATH", 'password', 'sufficient', 'pam_unix.so', "$var_password_hashing_algorithm_pam", '', '') }}}

# Ensure only the correct hashing algorithm option is used.
declare -a HASHING_ALGORITHMS_OPTIONS=("sha512" "yescrypt" "gost_yescrypt" "blowfish" "sha256" "md5" "bigcrypt")

for hash_option in "${HASHING_ALGORITHMS_OPTIONS[@]}"; do
  if [ "$hash_option" != "$var_password_hashing_algorithm_pam" ]; then
    if grep -qP "^\s*password\s+.*\s+pam_unix.so\s+.*\b$hash_option\b" "$PAM_FILE_PATH"; then
      {{{ bash_remove_pam_module_option_configuration("$PAM_FILE_PATH", 'password', ".*", 'pam_unix.so', "$hash_option") }}}
    fi
  fi
done
