#!/bin/bash
# platform = multi_platform_debian

mkdir -p /etc/update-motd.d
printf '#!/bin/sh\nuname -snrvm\n' > /etc/update-motd.d/10-uname
chmod 0755 /etc/update-motd.d/10-uname
