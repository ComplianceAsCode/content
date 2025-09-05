# platform = Red Hat Virtualization 4,multi_platform_rhel,multi_platform_ol
. /usr/share/scap-security-guide/remediation_functions
populate var_accounts_user_umask

grep -q umask /etc/bashrc && \
  sed -i "s/umask.*/umask $var_accounts_user_umask/g" /etc/bashrc
if ! [ $? -eq 0 ]; then
    echo "umask $var_accounts_user_umask" >> /etc/bashrc
fi
