#!/bin/bash
# platform = Red Hat Enterprise Linux 7,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol

pam_file="/etc/pam.d/postlogin"

if ! $(grep -q "^[^#].*pam_lastlog.so.*showfailed" $pam_file); then
	sed -i --follow-symlinks '0,/^session.*/s/^session.*/session     optional                   pam_lastlog.so showfailed\n&/' "$pam_file"
else
	sed -r -i --follow-symlinks "s/(^session.*)(required|requisite)(.*pam_lastlog\.so.*)$/\1optional\3/" "$pam_file"
fi
