#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp
# platform = Red Hat Enterprise Linux 8

grub2-editenv - set "$(grub2-editenv - list | grep kernelopts) pti=on"
