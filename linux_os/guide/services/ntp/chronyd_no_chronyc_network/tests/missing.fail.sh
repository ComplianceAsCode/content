#!/bin/bash
#

yum install -y chrony
systemctl enable chronyd.service
