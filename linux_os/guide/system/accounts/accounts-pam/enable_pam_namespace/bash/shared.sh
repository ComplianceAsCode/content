# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_almalinux
if ! grep -Eq '^\s*session\s+required\s+pam_namespace.so\s*$' '/etc/pam.d/login' ; then
    echo "session    required     pam_namespace.so" >> "/etc/pam.d/login"
fi
