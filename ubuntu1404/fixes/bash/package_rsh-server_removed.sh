# platform = Ubuntu 1404
# CAUTION: This remediation script will remove rsh-server
#	   from the system, and may remove any packages
#	   that depend on rsh-server. Execute this
#	   remediation AFTER testing on a non-production
#	   system!

apt-get remove --purge rsh-server
