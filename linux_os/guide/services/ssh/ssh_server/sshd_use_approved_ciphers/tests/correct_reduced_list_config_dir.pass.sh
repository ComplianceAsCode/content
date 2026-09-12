#!/bin/bash
{{% if sshd_distributed_config == "false" %}}
# platform = Not Applicable
{{% else %}}
# platform = multi_platform_sle
{{% endif %}}

source include.sh
{{% if product in [ 'sle16', 'slmicro6' ] %}}
touch "{{{ sshd_main_config_file }}}"
{{% endif %}}

echo 'Ciphers aes128-ctr,aes192-ctr' >> "{{{ sshd_config_dir }}}/00-test.conf"
