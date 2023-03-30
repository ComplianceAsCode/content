#!/bin/bash
# platform = multi_platform_sle,multi_platform_ubuntu

sed -ri 's/(^shadow:[^:]*:[^:]*:)([^:]+$)/\1/' /etc/group
