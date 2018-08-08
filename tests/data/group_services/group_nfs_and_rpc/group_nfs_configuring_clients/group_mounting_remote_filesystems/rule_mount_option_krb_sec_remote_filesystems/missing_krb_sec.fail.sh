#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_stig-rhel7-disa

cp ../fstab /etc/
# delete sec=.. only from nfs4
sed -i 's|\(.*nfs4.*\),sec=krb5:krb5i:krb5p\(.*\)|\1\2|' /etc/fstab
