#!/bin/bash
# packages = bash

sed -i '/umask/d' /etc/bashrc
echo "umask 000" >> /etc/bashrc
echo "umask 000" >> /etc/bashrc
echo "umask 000" >> /etc/bashrc
umask 000
