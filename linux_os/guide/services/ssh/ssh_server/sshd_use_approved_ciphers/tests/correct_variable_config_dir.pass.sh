#!/bin/bash
{{% if sshd_distributed_config == "false" %}}
# platform = Not Applicable
{{% else %}}
# platform = multi_platform_sle
{{% endif %}}
# variables = sshd_approved_ciphers=ijkl158,sits,wwq-98,kl24

source include.sh
{{% if product in [ 'sle16', 'slmicro6' ] %}}
touch "{{{ sshd_main_config_file }}}"
{{% endif %}}

echo 'Ciphers ijkl158,sits,wwq-98,kl24' >> "{{{ sshd_config_dir }}}/00-test.conf"
