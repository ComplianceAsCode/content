#!/bin/bash
# platform = multi_platform_sle,multi_platform_slmicro,Ubuntu 20.04

{{% if product in ["sle12","sle15"] %}}
{{% set cfg_file = '/etc/pam.d/login' %}}
{{% else %}}
{{% set cfg_file = '/etc/pam.d/common-auth' %}}
{{% endif %}}

cat >/etc/pam.d/common-account <<CAPCM
account	[success=1 new_authtok_reqd=done default=ignore]	pam_unix.so
account	requisite			pam_deny.so
account	required			pam_permit.so
CAPCM

cat >{{{ cfg_file }}} <<CAUPACM
auth	[success=1 default=ignore]	pam_unix.so nullok_secure
auth	requisite			pam_deny.so
auth	required			pam_permit.so
auth	optional			pam_cap.so
CAUPACM
