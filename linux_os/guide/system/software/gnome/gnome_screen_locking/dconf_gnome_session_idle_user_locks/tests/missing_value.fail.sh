#!/bin/bash
# packages = dconf,gdm

. $SHARED/dconf_test_functions.sh

clean_dconf_settings

dconf update
