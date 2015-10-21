# CAUTION: This remediation script will remove telnet
#	   from the system, and may remove any packages
#	   that depend on telnet. Execute this
#	   remediation AFTER testing on a non-production
#	   system!
yum -y erase telnet
