#!/bin/bash
# packages = chrony

systemctl stop chronyd
systemctl disable chronyd
systemctl mask chronyd
