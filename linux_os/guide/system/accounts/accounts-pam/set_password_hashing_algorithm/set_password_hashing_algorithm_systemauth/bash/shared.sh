# platform = multi_platform_all

{{{ bash_instantiate_variables("var_password_hashing_algorithm_pam") }}}

{{% if 'sle' in product or 'slmicro' in product -%}}
PAM_FILE_PATH="/etc/pam.d/common-password"
CONTROL="required"
{{%- elif 'ubuntu' in product -%}}
PAM_FILE_PATH="/etc/pam.d/common-password"
{{%- else -%}}
PAM_FILE_PATH="/etc/pam.d/system-auth"
CONTROL="sufficient"
{{%- endif %}}

{{% if 'ubuntu' in product -%}}
# Can't use macro bash_ensure_pam_module_configuration because the control
# contains special characters and is not static ([success=N default=ignore)
if ! grep -qP "^\s*password\s+.*\s+pam_unix.so\s+.*\b$var_password_hashing_algorithm_pam\b" "$PAM_FILE_PATH"; then
  sed -i -E --follow-symlinks "/\s*password\s+.*\s+pam_unix.so.*/ s/$/ $var_password_hashing_algorithm_pam/" "$PAM_FILE_PATH"
fi
{{%- else -%}}
{{{ bash_ensure_pam_module_configuration("$PAM_FILE_PATH", 'password', "$CONTROL", 'pam_unix.so', "$var_password_hashing_algorithm_pam", '', '') }}}
{{%- endif %}}

# Ensure only the correct hashing algorithm option is used.
declare -a HASHING_ALGORITHMS_OPTIONS=("sha512" "yescrypt" "gost_yescrypt" "blowfish" "sha256" "md5" "bigcrypt")

for hash_option in "${HASHING_ALGORITHMS_OPTIONS[@]}"; do
  if [ "$hash_option" != "$var_password_hashing_algorithm_pam" ]; then
    if grep -qP "^\s*password\s+.*\s+pam_unix.so\s+.*\b$hash_option\b" "$PAM_FILE_PATH"; then
      {{{ bash_remove_pam_module_option_configuration("$PAM_FILE_PATH", 'password', ".*", 'pam_unix.so', "$hash_option") }}}
    fi
  fi
done
