#!/bin/bash

source common.sh

{{{ bash_sshd_remediation(parameter=PARAMETER, value=VALUE, config_is_distributed=sshd_distributed_config) -}}}
