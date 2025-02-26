#!/bin/bash
# packages = ntp


echo "restrict -4 default kod nomodify notrap nopeer noquery" > /etc/ntpsec/ntp.conf
# this one is not complete
echo "restrict -6 default kod nomodify notrap nopeer" >> /etc/ntpsec/ntp.conf
