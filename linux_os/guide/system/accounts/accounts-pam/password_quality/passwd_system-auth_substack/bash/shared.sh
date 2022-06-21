# platform = multi_platform_ol

if ! grep -Eq "^[\s]*password[\s]+substack[\s]+system-auth\s*$" /etc/pam.d/passwd; then
    echo 'password    substack    system-auth' >> /etc/pam.d/passwd
fi
