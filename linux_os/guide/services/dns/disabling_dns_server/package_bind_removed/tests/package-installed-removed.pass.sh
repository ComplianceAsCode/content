#!/bin/bash

{{% if product == "rhel9" -%}}
dnf install -y bind9.18 || dnf install -y bind
dnf remove -y bind9.18
dnf -y remove bind
{{% elif 'ubuntu' in product -%}}
{{{ bash_package_install("bind9") }}}
{{{ bash_package_remove("bind9") }}}
{{% else -%}}
{{{ bash_package_install("bind") }}}
{{{ bash_package_remove("bind") }}}
{{% endif -%}}
