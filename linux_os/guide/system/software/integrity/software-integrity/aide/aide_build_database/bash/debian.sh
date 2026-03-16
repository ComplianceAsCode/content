# platform = multi_platform_debian

{{{ bash_package_install("aide") }}}

AIDE_VERSION=$(aide -v | grep -oP 'aide \K[0-9]+\.[0-9]+')
if [ "$(echo "$AIDE_VERSION >= 0.17" | bc -l)" -eq 1 ]; then
    AIDE_DB__KEY="database_in"
else
    AIDE_DB_IN_KEY="database"
fi
AIDE_CONFIG=/etc/aide/aide.conf
DEFAULT_DB_PATH=/var/lib/aide/aide.db

# Fix db path in the config file, if necessary
if ! grep -q "^${AIDE_DB_IN_KEY}=file:" ${AIDE_CONFIG}; then
    # replace_or_append gets confused by 'database=file' as a key, so should not be used.
    #replace_or_append "${AIDE_CONFIG}" '^database=file' "${DEFAULT_DB_PATH}" '@CCENUM@' '%s:%s'
    echo "${AIDE_DB_IN_KEY}=file:${DEFAULT_DB_PATH}" >> ${AIDE_CONFIG}
fi

# Fix db out path in the config file, if necessary
if ! grep -q '^database_out=file:' ${AIDE_CONFIG}; then
    echo "database_out=file:${DEFAULT_DB_PATH}.new" >> ${AIDE_CONFIG}
fi

/usr/sbin/aideinit -y -f
