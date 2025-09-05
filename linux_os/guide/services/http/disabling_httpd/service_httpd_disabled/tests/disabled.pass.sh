#!/bin/bash
# packages = httpd

systemctl stop httpd
systemctl disable httpd
systemctl mask httpd
