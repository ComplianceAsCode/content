#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp

. shared.sh

interval="900"
set_default_configuration

preauth_set=1
authfail_set=1
account_set=1
auth_file="/etc/pam.d/system-auth"

insert_or_remove_settings $preauth_set $authfail_set $account_set $interval $auth_file

preauth_set=0
authfail_set=0
account_set=0
auth_file="/etc/pam.d/password-auth"

insert_or_remove_settings $preauth_set $authfail_set $account_set $interval $auth_file
