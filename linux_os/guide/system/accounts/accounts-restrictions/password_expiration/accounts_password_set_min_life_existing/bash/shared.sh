#!/bin/bash

# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{{ bash_instantiate_variables("var_accounts_minimum_age_login_defs") }}}

usrs_min_pass_age=( $(awk -v var="$var_accounts_minimum_age_login_defs" -F: '$4 < var || $4 == "" {print $1}' /etc/shadow) )
for i in ${usrs_min_pass_age[@]};
do
  passwd -n $var_accounts_minimum_age_login_defs $i
done
