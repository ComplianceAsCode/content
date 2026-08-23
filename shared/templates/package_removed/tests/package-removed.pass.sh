#!/bin/bash

{{% for package in PACKAGES %}}
{{{ bash_package_remove(package) }}}
{{% endfor %}}
