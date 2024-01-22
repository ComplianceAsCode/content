# platform = multi_platform_all
# reboot = false
# complexity = low
# strategy = configure
# disruption = low

{{{ bash_package_install("firewalld") }}}

if systemctl is-active firewalld; then
    firewall-cmd --permanent --zone=trusted --add-interface=lo
    firewall-cmd --reload
else
    echo "
    firewalld service is not active. Remediation aborted!
    This remediation could not be applied because it depends on firewalld service running.
    The service is not started by this remediation in order to prevent connection issues."
fi
