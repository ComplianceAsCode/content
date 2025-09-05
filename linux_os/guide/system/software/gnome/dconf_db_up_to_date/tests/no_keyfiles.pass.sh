#!/bin/bash
# packages = dconf,gdm

. $SHARED/dconf_test_functions.sh

install_dconf_and_gdm_if_needed

clean_dconf_settings
