#!/bin/bash
# platform = multi_platform_all

sed -i '/^shadow:[^:]*:[^:]*:.*/d' /etc/group
