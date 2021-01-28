#!/bin/bash
# platform = Red Hat Virtualization 4,Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,Fedora,Oracle Linux 7,Oracle Linux 8,WRLinux 1019

find / -not -fstype afs -not -fstype ceph -not -fstype cifs -not -fstype smb3 -not -fstype smbfs -not -fstype sshfs -not -fstype ncpfs -not -fstype ncp -not -fstype nfs -not -fstype nfs4 -not -fstype gfs -not -fstype gfs2 -not -fstype glusterfs -not -fstype gpfs -not -fstype pvfs2 -not -fstype ocfs2 -not -fstype lustre -not -fstype davfs -not -fstype fuse.sshfs -type d -perm -0002 -uid +0 -exec chown root {} \;
