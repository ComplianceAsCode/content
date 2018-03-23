# platform = Ubuntu 1404
# CAUTION: This remediation script will remove talk
#	   from the system, and may remove any packages
#	   that depend on talk. Execute this
#	   remediation AFTER testing on a non-production
#	   system!

apt-get remove --purge talk
