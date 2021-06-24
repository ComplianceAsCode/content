#!/bin/bash

# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{{ bash_instantiate_variables("var_accounts_maximum_age_login_defs") }}}

usrs_max_pass_age=( $(awk -F: '$5 > var_accounts_maximum_age_login_defs || $5 == "" {print $1}' /etc/shadow) )
for i in ${usrs_max_pass_age[@]};
do
  passwd -x $var_accounts_maximum_age_login_defs $i
done
