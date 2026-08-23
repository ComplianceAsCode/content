#!/bin/bash
# packages = systemd-journal-remote
# platform = multi_platform_ubuntu
# variables = var_journal_upload_server_key_file=/etc/ssl/private/journal-upload.pem,var_journal_upload_server_certificate_file=/etc/ssl/certs/journal-upload.pem,var_journal_upload_server_trusted_certificate_file=/etc/ssl/ca/trusted.pem

a_settings=("URL=192.168.50.42" "ServerKeyFile=/etc/ssl/private/journal-upload.pem" \
    "ServerCertificateFile=/etc/ssl/certs/journal-upload.pem" "TrustedCertificateFile=/etc/ssl/ca/trusted1.pem")
[ ! -d /etc/systemd/journal-upload.conf.d/ ] && mkdir /etc/systemd/journal-upload.conf.d/
if grep -Psq -- '^\h*\[Upload\]' /etc/systemd/journal-upload.conf.d/60-journald_upload.conf; then
    printf '%s\n' "" "${a_settings[@]}" >> /etc/systemd/journal-upload.conf.d/60-journald_upload.conf
else
    printf '%s\n' "" "[Upload]" "${a_settings[@]}" >> /etc/systemd/journal-upload.conf.d/60-journald_upload.conf
fi
