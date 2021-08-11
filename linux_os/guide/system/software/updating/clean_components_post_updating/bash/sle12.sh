# platform = SUSE Linux Enterprise 12
. /usr/share/scap-security-guide/remediation_functions

{{{ bash_replace_or_append('/etc/zypp/zypp.conf', '^solver.upgradeRemoveDroppedPackages', 'true', '@CCENUM@', '%s=%s') }}}
