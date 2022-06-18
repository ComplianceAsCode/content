#!/bin/bash

SSHD_PARAM={{{ PARAMETER }}}
{{%- if XCCDF_VARIABLE is none or XCCDF_VARIABLE is not defined -%}}
SSHD_VAL={{{ VALUE }}}
{{%- else -%}}
{{{ bash_instantiate_variables(XCCDF_VARIABLE) }}}
SSHD_VAL="{{{ "${" + XCCDF_VARIABLE + "}" }}}"
{{%- endif -%}}

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing
