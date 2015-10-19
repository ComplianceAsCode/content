# platform = multi_platform_rhel
# CAUTION: This remediation script will remove rsh-server
#	   from the system, and may remove any packages
#	   that depend on rsh-server. Execute this
#	   remediation AFTER testing on a non-production
#	   system!
yum -y erase rsh-server
