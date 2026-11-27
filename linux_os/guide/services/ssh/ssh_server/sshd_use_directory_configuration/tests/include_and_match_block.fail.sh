#!/bin/bash
{{% if 'suse' in families %}}
# platform = Not Applicable
{{% else %}}
# platform = multi_platform_all
{{% endif %}}

# The distribution default Include directive at the top, followed by a Match block
rm -f "{{{ sshd_config_dir }}}/sshd_config_original.conf"
mkdir -p "{{{ sshd_config_dir }}}"
cat > "{{{ sshd_main_config_file }}}" << EOF
Include {{{ sshd_config_dir }}}/*.conf
Match Group sftponly
    ForceCommand internal-sftp
EOF
