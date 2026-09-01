#!/bin/bash
# DISA STIG V-258002 allows both "no" and "delayed".
# The custom OVAL in oval/shared.xml checks for (no|delayed) with a
# hardcoded value.

source common.sh

{{{ bash_sshd_remediation(parameter="Compression", value="delayed", config_is_distributed=sshd_distributed_config, rule_id=rule_id) -}}}
