# platform = multi_platform_all
# reboot = true
# strategy = restrict
# complexity = low
# disruption = low

# remove packages
{{% for package in xwindows_packages %}}
{{{ bash_package_remove(package) }}}
{{% endfor %}}
