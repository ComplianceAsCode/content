#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel,multi_platform_almalinux
{{% if product == 'rhel8' -%}}
# remediation = none
{{%- endif %}}

{{{ bash_replace_or_append('/etc/ssh/sshd_config', '^MACs', "wrong_value_expected_to_fail.com", '%s %s') }}}
