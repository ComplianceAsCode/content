#!/bin/bash

source common.sh

{{%- if XCCDF_VARIABLE %}}
# variables = {{{ XCCDF_VARIABLE }}}={{{ CORRECT_VALUE }}}
{{% endif %}}
{{{ bash_sshd_remediation(parameter=PARAMETER, value=CORRECT_VALUE, config_is_distributed=sshd_distributed_config) -}}}
