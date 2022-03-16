#!/bin/bash
rm -rf /tmp/tmp-inst
mkdir --mode 000 /tmp/tmp-inst
mkdir -p /etc/security/namespace.d
echo "/tmp     /tmp/tmp-inst/        user:create=0700:mntopts=nosuid,noexec,nodev      ~user,foo-bar" >> /etc/security/namespace.d/10-local.conf
