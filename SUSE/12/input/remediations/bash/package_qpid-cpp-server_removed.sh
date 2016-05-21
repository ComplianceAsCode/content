# platform = Red Hat Enterprise Linux 7
# CAUTION: This remediation script will remove qpid-cpp-server
#	   from the system, and may remove any packages
#	   that depend on qpid-cpp-server. Execute this
#	   remediation AFTER testing on a non-production
#	   system!

# Include source function library.
. /usr/share/scap-security-guide/remediation_functions

package_command remove qpid-cpp-server
