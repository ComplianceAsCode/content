#!/bin/bash
# platform = multi_platform_sle,Ubuntu 20.04

cat >/etc/pam.d/common-account <<CACPCC
account	[success=1 new_authtok_reqd=done default=ignore]	pam_unix.so
account	requisite			pam_deny.so
account required                        pam_tally2.so
account	required			pam_permit.so
CACPCC

cat >/etc/pam.d/common-auth <<CAUPCC
auth required pam_tally2.so onerr=fail audit silent deny=3 unlock_time=900
auth	[success=1 default=ignore]	pam_unix.so nullok_secure
auth	requisite			pam_deny.so
auth	required			pam_permit.so
auth	optional			pam_cap.so
CAUPCC

