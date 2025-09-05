#!/bin/bash
# platform = multi_platform_sle,Ubuntu 20.04

cat >/etc/pam.d/common-account <<CAPCM
account	[success=1 new_authtok_reqd=done default=ignore]	pam_unix.so
account	requisite			pam_deny.so
account	required			pam_permit.so
CAPCM

cat >/etc/pam.d/common-auth <<CAUPACM
auth	[success=1 default=ignore]	pam_unix.so nullok_secure
auth	requisite			pam_deny.so
auth	required			pam_permit.so
auth	optional			pam_cap.so
CAUPACM

