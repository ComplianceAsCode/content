#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_NOTFOUND

sed -i '/.*umask.*/d' /etc/init.d/functions
