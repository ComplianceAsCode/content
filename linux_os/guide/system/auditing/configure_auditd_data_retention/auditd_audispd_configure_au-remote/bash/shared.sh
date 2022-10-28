# platform = multi_platform_ol,multi_platform_rhel

if rpm --quiet -q audispd-plugins; then
    AUREMOTECONFIG={{{ audisp_conf_path }}}/plugins.d/au-remote.conf
    if [ -e "$AUREMOTECONFIG" ]; then
        {{{ bash_replace_or_append("$AUREMOTECONFIG", '^active', 'yes') }}}
        {{{ bash_replace_or_append("$AUREMOTECONFIG", '^direction', 'out') }}}
        {{{ bash_replace_or_append("$AUREMOTECONFIG", '^path', '/sbin/audisp-remote') }}}
        {{{ bash_replace_or_append("$AUREMOTECONFIG", '^type', 'always') }}}
    fi
fi
