#!/bin/bash

{{{ bash_package_remove("xorg-x11-server-Xorg") }}}
{{{ bash_package_remove("xorg-x11-server-utils") }}}
{{{ bash_package_remove("xorg-x11-server-common") }}}
{{% if product not in ["rhel7", "ol7"] %}}
{{{ bash_package_remove("xorg-x11-server-Xwayland") }}}
{{% endif %}}
