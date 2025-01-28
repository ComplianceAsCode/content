# platform = multi_platform_slmicro,multi_platform_ubuntu

{{{ bash_comment_config_line("/etc/systemd/journal-upload.conf(\.d/[^/]+\.conf)", '^URL') }}}

mkdir -p /etc/systemd/journal-upload.conf.d
touch /etc/systemd/journal-upload.conf.d/60-journald_upload.conf
{{{ bash_instantiate_variables("var_journal_upload_url") }}}
{{{ bash_replace_or_append('/etc/systemd/journal-upload.conf.d/60-journald_upload.conf', '^URL', "$var_journal_upload_url", '%s=%s') }}}

