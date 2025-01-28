#!/bin/bash
# packages = systemd-journal-remote
# variables = var_journal_upload_url=192.168.50.42

a_settings=("URL=192.168.50.42" "ServerKeyFile=/etc/ssl/private/journal-upload.pem" \
    "ServerCertificateFile=/etc/ssl/certs/journal-upload.pem" "TrustedCertificateFile=/etc/ssl/ca/trusted.pem")
[ ! -f /etc/systemd/journal-upload.conf ] && mkdir /etc/systemd/journal-upload.conf
if grep -Psq -- '^\h*\[Upload\]' /etc/systemd/journal-upload.conf; then
    printf '%s\n' "" "${a_settings[@]}" >> /etc/systemd/journal-upload.conf
else
    printf '%s\n' "" "[Upload]" "${a_settings[@]}" >> /etc/systemd/journal-upload.conf
fi
