#!/bin/bash
# based on shared/templates/package_removed/tests/package-installed-removed.pass.sh

# install packages
{{% for package in xwindows_packages %}}
{{{ bash_package_install(package) }}}
{{% endfor %}}

# remove packages
{{% for package in xwindows_packages %}}
{{{ bash_package_remove(package) }}}
{{% endfor %}}
