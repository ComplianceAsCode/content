#!/bin/bash
# packages = ntp


echo "restrict -4 default kod nomodify notrap nopeer noquery" > /etc/ntpsec/ntp.conf
