#!/bin/bash
# platform = multi_platform_all

sed -i "/#includedir/d" /etc/sudoers
echo "#includedir /opt/extra_config.d" >> /etc/sudoers
