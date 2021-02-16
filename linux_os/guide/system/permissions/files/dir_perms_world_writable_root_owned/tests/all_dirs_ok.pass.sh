#!/bin/bash

find / -not -fstype afs -not -fstype ceph -not -fstype cifs -not -fstype smb3 -not -fstype smbfs -not -fstype sshfs -not -fstype ncpfs -not -fstype ncp -not -fstype nfs -not -fstype nfs4 -not -fstype gfs -not -fstype gfs2 -not -fstype glusterfs -not -fstype gpfs -not -fstype pvfs2 -not -fstype ocfs2 -not -fstype lustre -not -fstype davfs -type d -perm -0002 -uid +0 -exec chown root {} \;
