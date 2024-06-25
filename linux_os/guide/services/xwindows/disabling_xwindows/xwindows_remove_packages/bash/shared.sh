# platform = multi_platform_all
# reboot = true
# strategy = restrict
# complexity = low
# disruption = low


# remove packages
{{{ bash_package_remove("xorg-x11-server-Xorg") }}}
{{{ bash_package_remove("xorg-x11-server-utils") }}}
{{{ bash_package_remove("xorg-x11-server-common") }}}
{{% if product not in ["ol7"] %}}
{{{ bash_package_remove("xorg-x11-server-Xwayland") }}}
{{% endif %}}
