#!/bin/bash

# platform = multi_platform_fedora,Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 9,Red Hat Enterprise Linux 10,multi_platform_ubuntu
{{%- if XCCDF_VARIABLE %}}
# variables = {{{ XCCDF_VARIABLE }}}={{{ CORRECT_VALUE }}}
{{%- endif %}}

source common.sh

{{% if product in ["ol8", "ol9"] %}}
{{{ bash_replace_or_append("/etc/ssh/sshd_config", "Include", "/etc/ssh/sshd_config.d/*.conf", "%s %s", cce_identifiers=cce_identifiers) }}}
{{% endif %}}

{{{ bash_sshd_remediation(parameter=PARAMETER, value=CORRECT_VALUE, config_is_distributed=sshd_distributed_config, rule_id=rule_id) -}}}

