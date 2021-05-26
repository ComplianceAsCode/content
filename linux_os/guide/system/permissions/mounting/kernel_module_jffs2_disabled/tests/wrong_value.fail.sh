#!/bin/bash

touch /etc/modprobe.d/jffs2.conf
sed -i '/install jffs2/d' /etc/modprobe.d/jffs2.conf
