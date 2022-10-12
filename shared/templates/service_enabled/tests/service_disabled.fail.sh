#!/bin/bash
{{% if SERVICENAME == sshd %}}
# platform = Not Applicable
{{% endif%}}
# packages = {{{ PACKAGENAME }}}

SYSTEMCTL_EXEC='/usr/bin/systemctl'
"$SYSTEMCTL_EXEC" stop '{{{ DAEMONNAME }}}.service'
"$SYSTEMCTL_EXEC" disable '{{{ DAEMONNAME }}}.service'
