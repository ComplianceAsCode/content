#!/bin/bash

# platform = multi_platform_fedora,Red Hat Enterprise Linux 9

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing

{{{ bash_sshd_remediation(parameter=PARAMETER, value=VALUE, config_is_distributed=true) -}}}
