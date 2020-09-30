#!/bin/bash

cp $SHARED/fstab /etc/
sed -i 's|\(.*nfs4.*\),noexec\(.*\)|\1\2|' /etc/fstab
