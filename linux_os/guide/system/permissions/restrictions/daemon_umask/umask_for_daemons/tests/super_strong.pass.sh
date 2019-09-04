#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_NOTFOUND

sed -i 's/.*umask.*/umask 077/g' /etc/init.d/functions
