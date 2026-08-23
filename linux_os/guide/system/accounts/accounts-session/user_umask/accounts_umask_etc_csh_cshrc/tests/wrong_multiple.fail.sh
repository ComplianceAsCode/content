#!/bin/bash

sed -i '/umask/d' /etc/csh.cshrc
echo "umask 000" >> /etc/csh.cshrc
echo "umask 000" >> /etc/csh.cshrc
echo "umask 000" >> /etc/csh.cshrc
umask 000
