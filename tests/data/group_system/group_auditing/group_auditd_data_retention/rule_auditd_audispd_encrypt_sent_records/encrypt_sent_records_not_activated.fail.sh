#!/bin/bash
# profiles = profile_not_found
# remediation = bash

yum install -y audispd-plugins

. ../set_parameters_value.sh
set_parameters_value /etc/audisp/audisp-remote.conf "enable_krb5" "no"
