#!/bin/bash
# packages = rhnsd

systemctl stop rhnsd
systemctl disable rhnsd
systemctl mask rhnsd
