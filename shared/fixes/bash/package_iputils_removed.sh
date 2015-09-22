# CAUTION: This remediation script will remove iputils
#	   from the system, and may remove any packages
#	   that depend on iputils. Execute this
#	   remediation AFTER testing on a non-production
#	   system!
yum -y erase iputils
