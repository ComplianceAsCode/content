#!/bin/bash
# packages = ntp


echo "restrict -4 default kod nomodify notrap nopeer noquery" > /etc/ntp.conf
# last two are swapped
echo "restrict -6 default kod nomodify notrap noquery nopeer" >> /etc/ntp.conf
