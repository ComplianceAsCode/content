#!/bin/bash
# packages = systemd-journal-remote
# variables = var_journal_upload_server_key_file=/etc/ssl/private/journal-upload.pem,var_journal_upload_server_certificate_file=/etc/ssl/certs/journal-upload.pem,var_journal_upload_server_trusted_certificate_file=/etc/ssl/ca/trusted.pem

{{{ bash_comment_config_line("/etc/systemd/journal-upload.conf(\.d/[^/]+\.conf)", '^ServerKeyFile') }}}
{{{ bash_comment_config_line("/etc/systemd/journal-upload.conf(\.d/[^/]+\.conf)", '^ServerCertificateFile') }}}
{{{ bash_comment_config_line("/etc/systemd/journal-upload.conf(\.d/[^/]+\.conf)", '^TrustedCertificateFile') }}}

