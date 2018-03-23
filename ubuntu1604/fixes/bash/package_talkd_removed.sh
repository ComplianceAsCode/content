# platform = Ubuntu 1604
# CAUTION: This remediation script will remove talkd
#	   from the system, and may remove any packages
#	   that depend on talkd. Execute this
#	   remediation AFTER testing on a non-production
#	   system!

apt-get remove --purge talkd
