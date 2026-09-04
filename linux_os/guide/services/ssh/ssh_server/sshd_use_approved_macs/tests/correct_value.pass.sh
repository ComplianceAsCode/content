#!/bin/bash
# platform = multi_platform_sle
# variables = sshd_approved_macs=hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256

source include.sh
{{% if product in [ 'sle16', 'slmicro6' ] %}}
touch "{{{ sshd_main_config_file }}}"
{{% endif %}}
echo 'MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256' >> "{{{ sshd_main_config_file }}}"
