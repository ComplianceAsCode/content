#!/bin/bash
# platform = multi_platform_sle,multi_platform_ubuntu

sed -i '/^shadow:[^:]*:[^:]*:/ s/$/vnc/' /etc/group
