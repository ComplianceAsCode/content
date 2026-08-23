#!/bin/bash

{{% if product in ["rhel9", "rhel10", "sle15", "sle16"] %}}
rm -rf "/etc/systemd/logind.conf.d/"
{{% endif %}}
