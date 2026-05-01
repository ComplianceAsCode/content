#!/bin/bash
# platform = SUSE Linux Enterprise 16
# packages = sudo

# remove /etc/sudoers, which is higher priority
# than /usr/etc/sudoers
if [ -e "/etc/sudoers" ] ; then
    rm "/etc/sudoers"
fi
# Allow root to execute commands on behalf of anybody
echo ' root ALL=(ALL) ALL' > /usr/etc/sudoers
echo 'root ALL= ALL' >> /usr/etc/sudoers
echo '# user ALL= ALL' >> /usr/etc/sudoers
