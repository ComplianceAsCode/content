# CAUTION: This remediation script will remove abrt
#	   from the system, and may remove any packages
#	   that depend on abrt. Execute this
#	   remediation AFTER testing on a non-production
#	   system!
yum -y erase abrt
