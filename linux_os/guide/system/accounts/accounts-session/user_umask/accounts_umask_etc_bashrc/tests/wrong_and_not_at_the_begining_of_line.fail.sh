#!/bin/bash
# packages = bash

sed -i '/umask/d' /etc/bashrc
echo "    [ \`umask\` -eq 0 ] && umask 022" >> /etc/bashrc
umask 000
