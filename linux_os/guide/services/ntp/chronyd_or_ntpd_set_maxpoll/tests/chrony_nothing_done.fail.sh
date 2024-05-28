#!/bin/bash
# packages = chrony
# variables = var_time_service_set_maxpoll=16
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7

{{{ bash_package_remove("ntp") }}}

systemctl enable chronyd.service
