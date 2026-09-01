#!/bin/bash
# platform = SUSE Linux Enterprise 16

{{% if XCCDF_VARIABLE %}}
# variables = {{{ XCCDF_VARIABLE }}}={{{ CORRECT_VALUE }}}
{{% endif %}}

if [ -e "{{{ sshd_main_config_file }}}" ] ; then
    rm "{{{ sshd_main_config_file }}}"
fi
# correct value in drop-in, but missing global main config
echo "{{{ PARAMETER }}} {{{ CORRECT_VALUE }}}" >> "{{{ sshd_config_dir }}}/other.conf"
