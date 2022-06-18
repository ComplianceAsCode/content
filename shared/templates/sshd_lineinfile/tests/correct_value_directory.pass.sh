#!/bin/bash

# platform = multi_platform_fedora,Red Hat Enterprise Linux 9

source common.sh

{{{ bash_sshd_remediation(parameter=PARAMETER, value=VALUE, config_is_distributed=true, xccdf_variable=XCCDF_VARIABLE) -}}}
