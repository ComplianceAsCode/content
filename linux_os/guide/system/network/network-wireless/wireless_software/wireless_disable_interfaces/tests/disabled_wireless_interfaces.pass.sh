#/bin/bash
# platform = Not Applicable
# This test is not runnable by automatus tool

{{{ bash_package_install("NetworkManager") }}}
nmcli radio wifi off
