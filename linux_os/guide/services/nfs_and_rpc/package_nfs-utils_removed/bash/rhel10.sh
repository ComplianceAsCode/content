# platform = Red Hat Enterprise Linux 10
# reboot = false
# strategy = disable
# complexity = low
# disruption = low

# This RHEL 10 special remediation is a workaround for
# https://issues.redhat.com/browse/RHEL-74244
# and once the issue is resolved we will remove it.
if {{{ bash_bootc_build() }}}; then
    mkdir -p /var/lib/rpm-state
fi

dnf -y remove nfs-utils
