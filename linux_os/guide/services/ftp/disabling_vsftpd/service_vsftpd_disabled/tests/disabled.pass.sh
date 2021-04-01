#!/bin/bash
# packages = vsftpd

systemctl stop vsftpd
systemctl disable vsftpd
systemctl mask vsftpd
