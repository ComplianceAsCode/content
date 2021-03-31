#!/bin/bash
# packages = cronie

systemctl stop crond
systemctl disable crond
systemctl mask crond
