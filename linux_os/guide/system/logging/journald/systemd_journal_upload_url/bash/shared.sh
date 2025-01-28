# platform = multi_platform_slmicro,multi_platform_ubuntu

{{% if 'ubuntu' in product %}}
var_journal_upload_conf_file=/etc/systemd/journal-upload.conf.d/60-journald_upload.conf
mkdir -p /etc/systemd/journal-upload.conf.d
touch /etc/systemd/journal-upload.conf.d/60-journald_upload.conf

{{{ bash_comment_config_line("/etc/systemd/journal-upload.conf(\.d/[^/]+\.conf)", '^URL') }}}
{{% else %}}
var_journal_upload_conf_file=/etc/systemd/journal-upload.conf
{{% endif %}}

{{{ bash_instantiate_variables("var_journal_upload_url") }}}
{{{ bash_replace_or_append('$var_journal_upload_conf_file', '^URL', "$var_journal_upload_url", '%s=%s') }}}

