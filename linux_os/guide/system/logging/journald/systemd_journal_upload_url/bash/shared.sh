# platform = multi_platform_slmicro

{{{ bash_instantiate_variables("var_journal_upload_url") }}}
{{{ bash_replace_or_append('/etc/systemd/journal-upload.conf', '^URL', "$var_journal_upload_url", '%s=%s') }}}
