#!/bin/bash
# packages = postfix

sed -i '/postmaster/d' /etc/aliases
