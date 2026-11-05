#!/bin/bash

# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 10,Red Hat Enterprise Linux 9,SUSE Linux Enterprise 16,multi_platform_fedora,multi_platform_ubuntu
{{%- if XCCDF_VARIABLE %}}
# variables = {{{ XCCDF_VARIABLE }}}={{{ CORRECT_VALUE }}}
{{%- endif %}}

source common.sh

# sshd ignores the drop-in directory because the main configuration file does not include it
sed -i "/^\s*Include\s/Id" "{{{ sshd_main_config_file }}}"
echo "{{{ PARAMETER }}} {{{ CORRECT_VALUE }}}" > "{{{ sshd_config_dir }}}/good_config.conf"
