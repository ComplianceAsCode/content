#!/bin/bash
rm -rf /var/tmp/tmp-inst
mkdir --mode 000 /var/tmp/tmp-inst
mkdir -p /etc/security/namespace.d
echo "/var/tmp /var/tmp/tmp-inst/    user:create=0700:mntopts=nosuid,noexec,nodev      ~user,foo-bar" >> /etc/security/namespace.d/10-local.conf
