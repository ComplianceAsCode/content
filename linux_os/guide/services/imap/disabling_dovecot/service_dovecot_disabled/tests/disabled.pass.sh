#!/bin/bash
# packages = dovecot

systemctl stop dovecot
systemctl disable dovecot
systemctl mask dovecot
