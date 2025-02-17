# platform = multi_platform_slmicro

{{{ bash_instantiate_variables("var_journal_upload_server_key_file") }}}
{{{ bash_replace_or_append('/etc/systemd/journal-upload.conf', '^ServerKeyFile', "$var_journal_upload_server_key_file", '%s=%s') }}}

{{{ bash_instantiate_variables("var_journal_upload_server_certificate_file") }}}
{{{ bash_replace_or_append('/etc/systemd/journal-upload.conf', '^ServerCertificateFile', "$var_journal_upload_server_certificate_file", '%s=%s') }}}

{{{ bash_instantiate_variables("var_journal_upload_server_trusted_certificate_file") }}}
{{{ bash_replace_or_append('/etc/systemd/journal-upload.conf', '^TrustedCertificateFile', "$var_journal_upload_server_trusted_certificate_file", '%s=%s') }}}
