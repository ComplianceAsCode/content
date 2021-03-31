#!/bin/bash
# packages = samba

systemctl stop smb
systemctl disable smb
systemctl mask smb
