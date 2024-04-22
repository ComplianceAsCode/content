# platform = multi_platform_all

{{% if product in ["sle15", "sle12"] -%}}
{{{ bash_ensure_pam_module_configuration('/etc/pam.d/common-password', 'password', 'required', 'pam_unix.so', 'sha512', '', '') }}}
{{% elif 'ubuntu' in product -%}}
# Can't use macro bash_ensure_pam_module_configuration because the control
# contains special characters and is not static ([success=N default=ignore)
PAM_FILE_PATH=/etc/pam.d/common-password
if ! grep -qP '^\s*password\s+.*\s+pam_unix.so\s+.*\s+sha512\b' "$PAM_FILE_PATH"; then
  sed -i -E --follow-symlinks '/\s*password\s+.*\s+pam_unix.so.*/ s/$/ sha512/' "$PAM_FILE_PATH"
fi
{{%- else -%}}
{{{ bash_ensure_pam_module_configuration('/etc/pam.d/system-auth', 'password', 'sufficient', 'pam_unix.so', 'sha512', '', '') }}}
{{%- endif %}}
