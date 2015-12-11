# platform = Debian 8
# CAUTION: This remediation script will remove gpm
#	   from the system, and may remove any packages
#	   that depend on gpm. Execute this
#	   remediation AFTER testing on a non-production
#	   system!

apt-get remove --purge gpm
