#!/bin/bash
# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_fedora,multi_platform_ubuntu

systemctl disable --now ctrl-alt-del.target
systemctl mask --now ctrl-alt-del.target
