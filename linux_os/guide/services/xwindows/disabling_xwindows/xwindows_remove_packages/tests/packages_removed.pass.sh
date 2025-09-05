#!/bin/bash

# install packages
{{% for package in xwindows_packages %}}
{{{ bash_package_remove(package) }}}
{{% endfor %}}
