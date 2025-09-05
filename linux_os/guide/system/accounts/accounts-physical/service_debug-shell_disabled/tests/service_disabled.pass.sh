#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp

systemctl disable debug-shell.service
systemctl stop debug-shell.service
systemctl mask debug-shell.service
