#!/bin/bash
# packages = ntp


echo "restrict -4 default kod nomodify notrap nopeer noquery" > /etc/ntpsec/ntp.conf
# last two are swapped
echo "restrict -6 default kod nomodify notrap noquery nopeer" >> /etc/ntpsec/ntp.conf
