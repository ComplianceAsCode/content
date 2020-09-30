#!/bin/bash


yum -y install /usr/lib/systemd/system/sssd.service
systemctl enable sssd
