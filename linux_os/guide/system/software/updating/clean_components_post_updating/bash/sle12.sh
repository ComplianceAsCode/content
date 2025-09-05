# platform = SUSE Linux Enterprise 12

{{{ bash_replace_or_append('/etc/zypp/zypp.conf', '^solver.upgradeRemoveDroppedPackages', 'true', '%s=%s') }}}
