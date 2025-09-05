#!/bin/bash
# packages = autofs

systemctl stop autofs
systemctl disable autofs
systemctl mask autofs
