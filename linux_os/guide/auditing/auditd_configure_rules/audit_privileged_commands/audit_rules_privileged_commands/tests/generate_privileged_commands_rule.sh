#!/bin/bash

AUID=$1
KEY=$2
RULEPATH=$3
for file in $(find / -not \( -fstype afs -o -fstype ceph -o -fstype cifs -o -fstype smb3 -o -fstype smbfs -o -fstype sshfs -o -fstype ncpfs -o -fstype ncp -o -fstype nfs -o -fstype nfs4 -o -fstype gfs -o -fstype gfs2 -o -fstype glusterfs -o -fstype gpfs -o -fstype pvfs2 -o -fstype ocfs2 -o -fstype lustre -o -fstype davfs -o -fstype fuse.sshfs \) -type f \( -perm -4000 -o -perm -2000 \) 2> /dev/null); do
     echo "-a always,exit -F path=$file -F perm=x -F auid>=$AUID -F auid!=unset -k $KEY" >> $RULEPATH
done
