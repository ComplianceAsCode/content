# platform = multi_platform_rhel, multi_platform_fedora
# CAUTION: This remediation script will remove net-snmp
#	   from the system, and may remove any packages
#	   that depend on net-snmp. Execute this
#	   remediation AFTER testing on a non-production
#	   system!
yum -y erase net-snmp
