# platform = multi_platform_slmicro,multi_platform_ubuntu

{{{ bash_comment_config_line("/etc/systemd/journal-upload.conf(\.d/[^/]+\.conf)", '^ServerKeyFile') }}}
{{{ bash_comment_config_line("/etc/systemd/journal-upload.conf(\.d/[^/]+\.conf)", '^ServerCertificateFile') }}}
{{{ bash_comment_config_line("/etc/systemd/journal-upload.conf(\.d/[^/]+\.conf)", '^TrustedCertificateFile') }}}

mkdir -p /etc/systemd/journal-upload.conf.d
touch /etc/systemd/journal-upload.conf.d/60-journald_upload.conf
{{{ bash_instantiate_variables("var_journal_upload_server_key_file") }}}
{{{ bash_replace_or_append('/etc/systemd/journal-upload.conf.d/60-journald_upload.conf', '^ServerKeyFile', "$var_journal_upload_server_key_file", '%s=%s') }}}

{{{ bash_instantiate_variables("var_journal_upload_server_certificate_file") }}}
{{{ bash_replace_or_append('/etc/systemd/journal-upload.conf.d/60-journald_upload.conf', '^ServerCertificateFile', "$var_journal_upload_server_certificate_file", '%s=%s') }}}

{{{ bash_instantiate_variables("var_journal_upload_server_trusted_certificate_file") }}}
{{{ bash_replace_or_append('/etc/systemd/journal-upload.conf.d/60-journald_upload.conf', '^TrustedCertificateFile', "$var_journal_upload_server_trusted_certificate_file", '%s=%s') }}}
