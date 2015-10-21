# CAUTION: This remediation script will remove prelink
#	   from the system, and may remove any packages
#	   that depend on prelink. Execute this
#	   remediation AFTER testing on a non-production
#	   system!
yum -y erase prelink
