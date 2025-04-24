#!/bin/bash

{{% if product == "rhel9" -%}}
dnf install -y bind9.18 || dnf install -y bind
{{% else -%}}
{{{ bash_package_install("bind") }}}
{{% endif -%}}
