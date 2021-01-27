#!/bin/bash

AUID=$1
KEY=$2
RULEPATH=$3
for file in $(find / -not -fstype afs -not -fstype ceph -not -fstype cifs -not -fstype smb3 -not -fstype smbfs -not -fstype sshfs -not -fstype ncpfs -not -fstype ncp -not -fstype nfs -not -fstype nfs4 -not -fstype gfs -not -fstype gfs2 -not -fstype glusterfs -not -fstype gpfs -not -fstype pvfs2 -not -fstype ocfs2 -not -fstype lustre -not -fstype davfs -not -fstype fuse.sshfs -type f -perm -4000 -o -type f -perm -2000 2>/dev/null); do
     echo "-a always,exit -F path=$file -F auid>=$AUID -F auid!=unset -k $KEY" >> $RULEPATH
done
