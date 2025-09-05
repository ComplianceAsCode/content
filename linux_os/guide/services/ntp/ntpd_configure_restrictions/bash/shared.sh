#!/bin/bash
# platform = Red Hat Enterprise Linux 7,multi_platform_fedora

{{{ set_config_file(path='/etc/ntp.conf', parameter='restrict -4', value='default kod nomodify notrap nopeer noquery', create='yes', insert_after='EOF', insert_before='', insensitive=true, separator=" ", separator_regex="\s\+", prefix_regex="^\s*") }}}
{{{ set_config_file(path='/etc/ntp.conf', parameter='restrict -6', value='default kod nomodify notrap nopeer noquery', create='yes', insert_after='EOF', insert_before='', insensitive=true, separator=" ", separator_regex="\s\+", prefix_regex="^\s*") }}}
