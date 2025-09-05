#!/bin/bash

# platform = multi_platform_fedora,Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 9,multi_platform_ubuntu

source common.sh

{{% if product in ["ol8", "ol9"] %}}
{{{ bash_replace_or_append("/etc/ssh/sshd_config", "Include", "/etc/ssh/sshd_config.d/*.conf", "%s %s") }}}
{{% endif %}}

{{{ bash_sshd_remediation(parameter=PARAMETER, value=VALUE, config_is_distributed=sshd_distributed_config) -}}}
