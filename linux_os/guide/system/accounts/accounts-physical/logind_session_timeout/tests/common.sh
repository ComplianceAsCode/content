#!/bin/bash

# this file prepares unified test environment used by other scenarios
# These should be tuned per product to match defaults

{{% if product in ["rhel9", "sle15", "sle16"] %}}
LOGIND_CONF_FILE="/etc/systemd/logind.conf.d/oscap-idle-sessions.conf"
mkdir -p /etc/systemd/logind.conf.d/
{{% else %}}
LOGIND_CONF_FILE="/etc/systemd/logind.conf"
{{% endif %}}
