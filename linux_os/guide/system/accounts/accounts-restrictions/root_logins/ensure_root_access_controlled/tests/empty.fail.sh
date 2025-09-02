#!/bin/bash
# packages = passwd
{{% if product == 'ubuntu2204' %}}
# platform = Not Applicable
{{% else %}}
# platform = multi_platform_all
{{% endif %}}
# remediation = none

passwd -d root
