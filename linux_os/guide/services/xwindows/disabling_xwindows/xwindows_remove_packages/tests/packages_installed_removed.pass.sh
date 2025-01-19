#!/bin/bash
# based on shared/templates/package_removed/tests/package-installed-removed.pass.sh

{{% if product in ["sle12", "sle15"] %}}
{{% set xwindows_packages = ['xorg-x11-server', 'xorg-x11-server-extra', 'xorg-x11-server-Xvfb', 'xwayland'] %}}
{{% elif 'ol7' in product %}}
{{% set xwindows_packages = ['xorg-x11-server-Xorg', 'xorg-x11-server-common', 'xorg-x11-server-utils'] %}}
{{% else %}}
{{% set xwindows_packages = ['xorg-x11-server-Xorg', 'xorg-x11-server-common', 'xorg-x11-server-utils', 'xorg-x11-server-Xwayland'] %}}
{{% endif %}}

# install packages
{{% for package in xwindows_packages %}}
{{{ bash_package_install(package) }}}
{{% endfor %}}

# remove packages
{{% for package in xwindows_packages %}}
{{{ bash_package_remove(package) }}}
{{% endfor %}}
