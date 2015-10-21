# platform = multi_platform_rhel
# CAUTION: This remediation script will remove dovecot
#	   from the system, and may remove any packages
#	   that depend on dovecot. Execute this
#	   remediation AFTER testing on a non-production
#	   system!
yum -y erase dovecot
