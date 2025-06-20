#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel,multi_platform_fedora,multi_platform_ubuntu

systemctl disable --now ctrl-alt-del.target
systemctl mask --now ctrl-alt-del.target
