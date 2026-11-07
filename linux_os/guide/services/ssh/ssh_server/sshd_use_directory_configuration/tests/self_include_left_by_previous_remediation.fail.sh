#!/bin/bash
{{% if 'suse' in families %}}
# platform = Not Applicable
{{% else %}}
# platform = multi_platform_all
{{% endif %}}

# Previous versions of the remediation moved the Include directive along with the rest of the configuration
mkdir -p "{{{ sshd_config_dir }}}"
cat > "{{{ sshd_config_dir }}}/sshd_config_original.conf" << EOF
Include {{{ sshd_config_dir }}}/*.conf
Match Group sftponly
    ForceCommand internal-sftp
EOF
cat > "{{{ sshd_main_config_file }}}" << EOF
# To modify the system-wide sshd configuration, create a  *.conf  file under
#  {{{ sshd_config_dir }}}/  which will be automatically included below

Include {{{ sshd_config_dir }}}/*.conf
EOF
