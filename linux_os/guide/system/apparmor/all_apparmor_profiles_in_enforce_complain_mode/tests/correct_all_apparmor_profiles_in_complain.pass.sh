#!/bin/bash
# packages = apparmor

#Replace apparmor definitions
apparmor_parser -q -r /etc/apparmor.d/
#Set all profiles in complain mode
aa-complain /etc/apparmor.d/*
