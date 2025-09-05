#!/bin/bash

{{% if product == "rhel9" -%}}
dnf install -y bind9.18 || dnf install -y bind
{{% elif 'ubuntu' in product -%}}
{{{ bash_package_install("bind9") }}}
{{% else -%}}
{{{ bash_package_install("bind") }}}
{{% endif -%}}
