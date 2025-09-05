#!/bin/bash
# packages = nfs-utils

mkdir -p /tmp/testdir/testdir2
mkdir /tmp/testmount
chown 2 /tmp/testdir/testdir2
chmod 777 /tmp/testdir/testdir2

echo '/tmp/testdir localhost(rw)' > /etc/exports
systemctl restart nfs-server
mount.nfs localhost:/tmp/testdir /tmp/testmount
