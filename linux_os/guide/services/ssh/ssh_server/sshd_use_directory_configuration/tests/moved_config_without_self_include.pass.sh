#!/bin/bash
# platform = multi_platform_all

mkdir -p "{{{ sshd_config_dir }}}"
cat > "{{{ sshd_config_dir }}}/sshd_config_original.conf" << EOF
# Include {{{ sshd_config_dir }}}/*.conf
Include /etc/crypto-policies/back-ends/opensshserver.config
Match Group sftponly
    ForceCommand internal-sftp
EOF
echo "Include {{{ sshd_config_dir }}}/*.conf" > "{{{ sshd_main_config_file }}}"
