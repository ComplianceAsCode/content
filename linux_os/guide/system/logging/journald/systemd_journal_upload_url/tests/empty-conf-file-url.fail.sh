#!/bin/bash
# packages = systemd-journal-remote
# variables = var_journal_upload_url=192.168.50.42

{{{ bash_comment_config_line("/etc/systemd/journal-upload.conf(\.d/[^/]+\.conf)", '^URL') }}}

