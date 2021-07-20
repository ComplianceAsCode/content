#!/bin/bash

if [ -f /etc/modprobe.d/jffs2.conf ]; then
    sed -i '/install jffs2/d' /etc/modprobe.d/jffs2.conf
fi
echo "# install jffs2 /bin/true" > /etc/modprobe.d/jffs2.conf
