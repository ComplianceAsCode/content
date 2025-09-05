# platform = Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,multi_platform_ol
# reboot = true
# strategy = restrict
# complexity = low
# disruption = low


# remove packages
{{{ bash_package_remove("xorg-x11-server-Xorg") }}}
{{{ bash_package_remove("xorg-x11-server-utils") }}}
{{{ bash_package_remove("xorg-x11-server-common") }}}
{{% if product not in ["rhel7", "ol7"] %}}
{{{ bash_package_remove("xorg-x11-server-Xwayland") }}}
{{% endif %}}

# configure run level
systemctl set-default multi-user.target