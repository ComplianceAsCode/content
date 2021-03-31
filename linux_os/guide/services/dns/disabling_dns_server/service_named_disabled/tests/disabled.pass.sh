#!/bin/bash
# packages = bind

systemctl stop named
systemctl disable named
systemctl mask named
