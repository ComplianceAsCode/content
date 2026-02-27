#!/bin/bash

# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 10,Red Hat Enterprise Linux 9,SUSE Linux Enterprise 16,multi_platform_fedora,multi_platform_ubuntu

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing

{{% if product in ["ol8", "ol9"] %}}
{{{ bash_replace_or_append("/etc/ssh/sshd_config", "Include", "/etc/ssh/sshd_config.d/*.conf", "%s %s", cce_identifiers=cce_identifiers) }}}
{{% endif %}}

declare -a SSHD_PATHS=("/etc/ssh/sshd_config" /etc/ssh/sshd_config.d/*)
{{% if product == 'sle16' %}}
SSHD_PATHS+=("/usr/etc/ssh/sshd_config" /usr/etc/ssh/sshd_config.d/*)
{{% endif %}}

if grep -q "^\s*{{{ PARAMETER }}}" "${SSHD_PATHS[@]}" ; then
    sed -i "/^\s*{{{ PARAMETER }}}.*/Id" "${SSHD_PATHS[@]}"
fi

{{% if XCCDF_VARIABLE %}}
# variables = {{{ XCCDF_VARIABLE }}}={{{ CORRECT_VALUE }}}
{{% endif %}}

echo "{{{ PARAMETER }}} {{{ CORRECT_VALUE }}}" >> /etc/ssh/sshd_config.d/first.conf
echo "{{{ PARAMETER }}} {{{ CORRECT_VALUE }}}" >> /etc/ssh/sshd_config.d/second.conf
