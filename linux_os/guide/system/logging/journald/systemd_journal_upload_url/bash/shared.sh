# platform = multi_platform_slmicro,multi_platform_ubuntu

{{{ bash_instantiate_variables("var_journal_upload_conf_file") }}}
{{{ bash_instantiate_variables("var_journal_upload_url") }}}
{{{ bash_replace_or_append('$var_journal_upload_conf_file', '^URL', "$var_journal_upload_url", '%s=%s') }}}

