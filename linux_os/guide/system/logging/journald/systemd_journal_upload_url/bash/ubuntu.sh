# platform = multi_platform_ubuntu

dropin_conf=/etc/systemd/journal-upload.conf.d/60-journald_upload.conf
mkdir -p /etc/systemd/journal-upload.conf.d
touch "${dropin_conf}"

for conf in /etc/systemd/journal-upload.conf /etc/systemd/journal-upload.conf.d/*; do
    [[ -e "${conf}" ]] || continue
    sed -i --follow-symlinks 's/^URL\>/#&/g' "${conf}"
done

{{{ bash_instantiate_variables("var_journal_upload_url") }}}

{{{ bash_ensure_ini_config("${dropin_conf}", 'Upload', 'URL', "$var_journal_upload_url") }}}
