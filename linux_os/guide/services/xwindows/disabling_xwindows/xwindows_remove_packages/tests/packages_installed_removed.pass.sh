#!/bin/bash
# based on shared/templates/package_removed/tests/package-installed-removed.pass.sh

{{{ bash_package_install("xorg-x11-server-Xorg") }}}
{{{ bash_package_install("xorg-x11-server-utils") }}}
{{{ bash_package_install("xorg-x11-server-common") }}}
{{% if product not in ["ol7"] %}}
{{{ bash_package_install("xorg-x11-server-Xwayland") }}}
{{% endif %}}

{{{ bash_package_remove("xorg-x11-server-Xorg") }}}
{{{ bash_package_remove("xorg-x11-server-utils") }}}
{{{ bash_package_remove("xorg-x11-server-common") }}}
{{% if product not in ["ol7"] %}}
{{{ bash_package_remove("xorg-x11-server-Xwayland") }}}
{{% endif %}}
