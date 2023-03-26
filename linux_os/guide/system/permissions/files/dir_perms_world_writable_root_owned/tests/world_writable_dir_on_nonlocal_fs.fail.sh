#!/bin/bash
# packages = nfs-utils
#   This test fails under podman as there seems to be problems setupping nfs
#   server, nfsd kernel module might not be loaded and so on
# skip_test_env = podman-based

mkdir -p /tmp/testdir/testdir2
mkdir /tmp/testmount
chown 2 /tmp/testdir/testdir2
chmod 777 /tmp/testdir/testdir2

echo '/tmp/testdir localhost(rw)' > /etc/exports
systemctl restart nfs-server
mount.nfs localhost:/tmp/testdir /tmp/testmount
