# platform = multi_platform_all

{{{ bash_instantiate_variables("var_password_hashing_algorithm_pam") }}}

{{% if 'sle' in product or 'slmicro' in product -%}}
PAM_FILE_PATH="/etc/pam.d/common-password"
{{% set control = "required" %}}
{{%- elif 'ubuntu' in product -%}}
{{{ bash_pam_unix_enable() }}}
PAM_FILE_PATH=/usr/share/pam-configs/cac_unix
{{%- else -%}}
PAM_FILE_PATH="/etc/pam.d/system-auth"
{{% set control = "sufficient" %}}
{{%- endif %}}

{{% if 'ubuntu' in product -%}}
if ! grep -qzP "Password:\s*\n\s+.*\s+pam_unix.so\s+.*\b$var_password_hashing_algorithm_pam\b" "$PAM_FILE_PATH"; then
  sed -i -E '/^Password:/,/^[^[:space:]]/ {
    /pam_unix\.so/ {
        s/$/ '"$var_password_hashing_algorithm_pam"'/g
    }
}' "$PAM_FILE_PATH"
fi

if ! grep -qzP "Password-Initial:\s*\n\s+.*\s+pam_unix.so\s+.*\b$var_password_hashing_algorithm_pam\b" "$PAM_FILE_PATH"; then
  sed -i -E '/^Password-Initial:/,/^[^[:space:]]/ {
    /pam_unix\.so/ {
        s/$/ '"$var_password_hashing_algorithm_pam"'/g
    }
}' "$PAM_FILE_PATH"
fi

{{%- else -%}}
{{{ bash_ensure_pam_module_configuration("$PAM_FILE_PATH", 'password', control, 'pam_unix.so', "$var_password_hashing_algorithm_pam", '', '') }}}
{{%- endif %}}

# Ensure only the correct hashing algorithm option is used.
declare -a HASHING_ALGORITHMS_OPTIONS=("sha512" "yescrypt" "gost_yescrypt" "blowfish" "sha256" "md5" "bigcrypt")

for hash_option in "${HASHING_ALGORITHMS_OPTIONS[@]}"; do
  if [ "$hash_option" != "$var_password_hashing_algorithm_pam" ]; then
    {{% if 'ubuntu' in product -%}}
      sed -i -E '/^Password:/,/^[^[:space:]]/ {
      /pam_unix\.so/ {
        s/\s*'"$hash_option"'//g
      }
      }' "$PAM_FILE_PATH"
      sed -i -E '/^Password-Initial:/,/^[^[:space:]]/ {
      /pam_unix\.so/ {
        s/\s*'"$hash_option"'//g
      }
      }' "$PAM_FILE_PATH"
      DEBIAN_FRONTEND=noninteractive pam-auth-update
    {{%- else -%}}
    if grep -qP "^\s*password\s+.*\s+pam_unix.so\s+.*\b$hash_option\b" "$PAM_FILE_PATH"; then
      {{{ bash_remove_pam_module_option_configuration("$PAM_FILE_PATH", 'password', ".*", 'pam_unix.so', "$hash_option") }}}
    fi
    {{%- endif %}}
  fi
done
