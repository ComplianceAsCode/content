# platform = multi_platform_ubuntu

dropin_conf=/etc/systemd/journal-upload.conf.d/60-journald_upload.conf
mkdir -p /etc/systemd/journal-upload.conf.d
touch "${dropin_conf}"

for conf in /etc/systemd/journal-upload.conf /etc/systemd/journal-upload.conf.d/*; do
    [[ -e "${conf}" ]] || continue
    sed -i --follow-symlinks \
        -e 's/^ServerKeyFile\>/#&/g' \
        -e 's/^ServerCertificateFile\>/#&/g' \
        -e 's/^TrustedCertificateFile\>/#&/g' "${conf}"
done

{{{ bash_instantiate_variables("var_journal_upload_server_key_file") }}}
{{{ bash_instantiate_variables("var_journal_upload_server_certificate_file") }}}
{{{ bash_instantiate_variables("var_journal_upload_server_trusted_certificate_file") }}}

{{{ bash_ensure_ini_config("${dropin_conf}", 'Upload', 'ServerKeyFile', "$var_journal_upload_server_key_file") }}}
{{{ bash_ensure_ini_config("${dropin_conf}", 'Upload', 'ServerCertificateFile', "$var_journal_upload_server_certificate_file") }}}
{{{ bash_ensure_ini_config("${dropin_conf}", 'Upload', 'TrustedCertificateFile', "$var_journal_upload_server_trusted_certificate_file") }}}

