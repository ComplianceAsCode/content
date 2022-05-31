#!/bin/bash

{{{ bash_package_remove("authselect") }}}

SSSD_FILE="/etc/sssd/sssd.conf"

truncate -s 0 $SSSD_FILE
