# platform = multi_platform_slmicro,multi_platform_ubuntu

{{{ bash_instantiate_variables("var_journal_upload_conf_file") }}}
{{{ bash_instantiate_variables("var_journal_upload_server_key_file") }}}
{{{ bash_replace_or_append('$var_journal_upload_conf_file', '^ServerKeyFile', "$var_journal_upload_server_key_file", '%s=%s') }}}

{{{ bash_instantiate_variables("var_journal_upload_server_certificate_file") }}}
{{{ bash_replace_or_append('$var_journal_upload_conf_file', '^ServerCertificateFile', "$var_journal_upload_server_certificate_file", '%s=%s') }}}

{{{ bash_instantiate_variables("var_journal_upload_server_trusted_certificate_file") }}}
{{{ bash_replace_or_append('$var_journal_upload_conf_file', '^TrustedCertificateFile', "$var_journal_upload_server_trusted_certificate_file", '%s=%s') }}}
