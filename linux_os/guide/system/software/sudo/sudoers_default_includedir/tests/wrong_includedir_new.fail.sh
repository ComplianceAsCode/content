#!/bin/bash
# platform = multi_platform_all

sed -i "/#includedir/d" /etc/sudoers
echo "@includedir /etc/sudoers.d" >> /etc/sudoers
