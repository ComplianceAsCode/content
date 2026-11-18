#!/bin/bash
# Replaces the templated scenario: these releases have no installable rsh client.
{{% if product in ["debian13", "rhel8", "rhel9", "sle15", "ubuntu2404", "ubuntu2604"] %}}
# platform = Not Applicable
{{% endif %}}
{{% if product in ["debian12", "debian13", "ubuntu2204", "ubuntu2404", "ubuntu2604"] %}}
{{{ bash_package_install("rsh-client") }}}
{{{ bash_package_remove("rsh-client") }}}
{{% else %}}
{{{ bash_package_install("rsh") }}}
{{{ bash_package_remove("rsh") }}}
{{% endif %}}
