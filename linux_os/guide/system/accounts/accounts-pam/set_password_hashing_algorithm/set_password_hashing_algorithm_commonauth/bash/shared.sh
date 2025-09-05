# platform = multi_platform_sle

{{{ bash_ensure_pam_module_options('/etc/pam.d/common-auth', 'auth', 'required', 'pam_unix.so', 'sha512', '', '') }}}
