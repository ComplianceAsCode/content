#!/bin/bash

. $SHARED/dconf_test_functions.sh

yum -y install dconf
clean_dconf_settings
