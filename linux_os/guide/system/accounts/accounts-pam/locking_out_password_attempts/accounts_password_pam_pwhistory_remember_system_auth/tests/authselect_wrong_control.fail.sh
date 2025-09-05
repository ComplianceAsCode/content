#!/bin/bash
# packages = authselect
# platform = Oracle Linux 8,Oracle Linux 9,Red Hat Enterprise Linux 8,Red Hat Enterprise Linux 9,multi_platform_fedora
# variables = var_password_pam_remember=5,var_password_pam_remember_control_flag=requisite

if authselect list-features minimal | grep -q with-pwhistory; then
    # There is no easy way to skip this test scenario in systems with "with-pwhistory" feature.
    # In these systems, if the controls of a existing feature are modified in authselect profiles,
    # this impacts directly in the feature behaviour and is strongly not recommended. In any case,
    # what would happen is that the remediation wouldn't change the control by using
    # "authselect enable-feature with-pwhistory". This test scenario is intended to catch custom
    # profiles which were incorrectly configured. In a system where the "with-pwhistory" feature
    # is available, it is not expected a custom profile changing out-of-box features.
    authselect select sssd --force
    authselect disable-feature with-pwhistory
else
    remember_cnt=5
    control=required
    authselect create-profile hardening -b sssd
    CUSTOM_PROFILE="custom/hardening"
    authselect select $CUSTOM_PROFILE --force
    CUSTOM_SYSTEM_AUTH="/etc/authselect/$CUSTOM_PROFILE/system-auth"
    if ! $(grep -q "^[^#].*pam_pwhistory\.so.*remember=" $CUSTOM_SYSTEM_AUTH); then
        sed -i --follow-symlinks "/^password.*required.*pam_pwquality\.so/a password    $control     pam_pwhistory.so remember=$remember_cnt use_authtok" $CUSTOM_SYSTEM_AUTH
    else
        sed -r -i --follow-symlinks "s/(^password.*)(required|requisite)(.*pam_pwhistory\.so.*)$/\1$control\3/" $CUSTOM_SYSTEM_AUTH
    fi
fi
authselect apply-changes -b
