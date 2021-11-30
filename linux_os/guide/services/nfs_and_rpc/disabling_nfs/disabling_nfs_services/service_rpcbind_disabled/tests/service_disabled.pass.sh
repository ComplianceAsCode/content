#!/bin/bash
# packages = nfs-utils

systemctl stop rpcbind.service
systemctl disable rpcbind.service
systemctl mask rpcbind.service
# rpcbind has also activation socket and we need to disable it to pass
systemctl stop rpcbind.socket
systemctl disable rpcbind.socket
systemctl mask rpcbind.socket
