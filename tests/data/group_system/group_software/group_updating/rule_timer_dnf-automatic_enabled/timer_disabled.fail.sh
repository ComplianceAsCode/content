#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp

dnf -y install dnf-automatic
systemctl disable --now dnf-automatic.timer
