#!/bin/bash
# platform = multi_platform_slmicro

cat >/etc/pam.d/common-account <<CAPTC
account	[success=1 new_authtok_reqd=done default=ignore]	pam_unix.so
account	requisite			pam_deny.so
account required			pam_tally2.so
account	required			pam_permit.so
CAPTC

cat >/etc/pam.d/login <<CAPTUTA
auth required pam_tally2.so file=/var/log/pam_tally2.log
auth	[success=1 default=ignore]	pam_unix.so nullok_secure
auth	requisite			pam_deny.so
auth	required			pam_permit.so
auth	optional			pam_cap.so
CAPTUTA
