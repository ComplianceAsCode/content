#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp

sed -i "/^CtrlAltDelBurstAction.*/d" /etc/systemd/system.conf
