#!/bin/bash
# platform = multi_platform_all

sed -i "/#include(dir)?/d" /etc/sudoers
