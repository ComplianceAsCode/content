#!/bin/bash
# packages = dconf,gdm

. $SHARED/dconf_test_functions.sh

clean_dconf_settings
add_dconf_setting "{{{ SECTION }}}" "{{{ PARAMETER }}}" "{{{ VALUE }}}" "{{{ DCONF_DATABASE_DIRECTORY }}}" "00-security-settings"
add_dconf_lock "{{{ SECTION }}}" "{{{ PARAMETER }}}" "{{{ DCONF_DATABASE_DIRECTORY }}}" "00-security-settings-lock"

dconf update
