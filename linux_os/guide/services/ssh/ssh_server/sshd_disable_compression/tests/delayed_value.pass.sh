#!/bin/bash

# the .var files are not available during testing (are parsed after the tests are run) so we need to set the variable directly
# variables = var_sshd_disable_compression=no|delayed

source common.sh

# Set sshd Compression to "delayed" and verify the OVAL test passes. DISA STIG V-258002 allows both "no" and "delayed".
{{{ bash_sshd_remediation(parameter="Compression", value="delayed", config_is_distributed=sshd_distributed_config, rule_id=rule_id) -}}}
