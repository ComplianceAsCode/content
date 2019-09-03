#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_C2S

. $SHARED/removable_partitions.sh

touch /dev/dvd
dvdrom_fstab_line noexec > /etc/fstab
