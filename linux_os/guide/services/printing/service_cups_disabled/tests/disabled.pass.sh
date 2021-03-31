#!/bin/bash
# packages = cups

systemctl stop cups
systemctl disable cups
systemctl mask cups
