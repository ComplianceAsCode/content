# platform = multi_platform_slmicro,multi_platform_ubuntu

{{% if 'ubuntu' in product %}}
var_journal_upload_conf_file=/etc/systemd/journal-upload.conf.d/60-journald_upload.conf
mkdir -p /etc/systemd/journal-upload.conf.d
touch /etc/systemd/journal-upload.conf.d/60-journald_upload.conf

{{{ bash_comment_config_line("/etc/systemd/journal-upload.conf(\.d/[^/]+\.conf)", '^ServerKeyFile') }}}
{{{ bash_comment_config_line("/etc/systemd/journal-upload.conf(\.d/[^/]+\.conf)", '^ServerCertificateFile') }}}
{{{ bash_comment_config_line("/etc/systemd/journal-upload.conf(\.d/[^/]+\.conf)", '^TrustedCertificateFile') }}}
{{% else %}}
var_journal_upload_conf_file=/etc/systemd/journal-upload.conf
{{% endif %}}

{{{ bash_instantiate_variables("var_journal_upload_server_key_file") }}}
{{{ bash_replace_or_append('$var_journal_upload_conf_file', '^ServerKeyFile', "$var_journal_upload_server_key_file", '%s=%s') }}}

{{{ bash_instantiate_variables("var_journal_upload_server_certificate_file") }}}
{{{ bash_replace_or_append('$var_journal_upload_conf_file', '^ServerCertificateFile', "$var_journal_upload_server_certificate_file", '%s=%s') }}}

{{{ bash_instantiate_variables("var_journal_upload_server_trusted_certificate_file") }}}
{{{ bash_replace_or_append('$var_journal_upload_conf_file', '^TrustedCertificateFile', "$var_journal_upload_server_trusted_certificate_file", '%s=%s') }}}

