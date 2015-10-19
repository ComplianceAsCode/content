# platform = multi_platform_rhel
# CAUTION: This remediation script will remove rsh
#	   from the system, and may remove any packages
#	   that depend on rsh. Execute this
#	   remediation AFTER testing on a non-production
#	   system!
yum -y erase rsh
