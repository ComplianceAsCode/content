#!/bin/bash
{{% if SERVICENAME == sshd %}}
# platform = Not Applicable
{{% endif%}}
# packages = {{{ PACKAGENAME }}}
# skip_test_env = {{{ SKIP_TEST_ENV }}}

SYSTEMCTL_EXEC='/usr/bin/systemctl'
"$SYSTEMCTL_EXEC" stop '{{{ DAEMONNAME }}}.service'
"$SYSTEMCTL_EXEC" disable '{{{ DAEMONNAME }}}.service'
