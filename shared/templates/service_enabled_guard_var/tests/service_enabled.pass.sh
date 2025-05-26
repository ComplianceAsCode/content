#!/bin/bash
{{% if SERVICENAME == "sshd" %}}
# platform = Not Applicable
{{% endif %}}
# packages = {{{ PACKAGENAME }}}
# variables = {{{ VARIABLE }}}={{{ VALUE }}}

SYSTEMCTL_EXEC='/usr/bin/systemctl'
"$SYSTEMCTL_EXEC" unmask '{{{ DAEMONNAME }}}.service'
"$SYSTEMCTL_EXEC" start '{{{ DAEMONNAME }}}.service'
"$SYSTEMCTL_EXEC" enable '{{{ DAEMONNAME }}}.service'
