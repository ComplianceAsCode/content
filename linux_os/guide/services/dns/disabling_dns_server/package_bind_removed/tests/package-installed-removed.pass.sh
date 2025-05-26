#!/bin/bash

{{% if product == "rhel9" -%}}
dnf install -y bind9.18 || dnf install -y bind
dnf remove -y bind9.18
dnf -y remove bind
{{% else -%}}
{{{ bash_package_install("bind") }}}
{{{ bash_package_remove("bind") }}}
{{% endif -%}}
