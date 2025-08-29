# platform = multi_platform_all

{{% if 'ol' in families %}}
FAILLOCK_CONF_FILES="/etc/security/faillock.conf"
{{% else %}}
FAILLOCK_CONF_FILES="/etc/security/faillock.conf /etc/pam.d/system-auth /etc/pam.d/password-auth"
{{% endif %}}
faillock_dirs=$(grep -oP "^\s*(?:auth.*pam_faillock.so.*)?dir\s*=\s*(\S+)" $FAILLOCK_CONF_FILES \
               | sed -r 's/.*=\s*(\S+)/\1/')

# Workaround for https://github.com/OpenSCAP/openscap/issues/2242: Use full
# path to semanage and restorecon commands to avoid the issue with the command
# not being found.
if [ -n "$faillock_dirs" ]; then
    for dir in $faillock_dirs; do
        if ! /usr/sbin/semanage fcontext -a -t faillog_t "$dir(/.*)?"; then
            /usr/sbin/semanage fcontext -m -t faillog_t "$dir(/.*)?"
        fi
        if [ ! -e $dir ]; then
            mkdir -p $dir
        fi
        /usr/sbin/restorecon -R -v $dir
    done
else
echo "
The pam_faillock.so dir option is not set in the system.
If this is not expected, make sure pam_faillock.so is properly configured."
fi
