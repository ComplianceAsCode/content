# platform = multi_platform_rhel
# CAUTION: This remediation script will remove ypbind
#	   from the system, and may remove any packages
#	   that depend on ypbind. Execute this
#	   remediation AFTER testing on a non-production
#	   system!
yum -y erase ypbind
