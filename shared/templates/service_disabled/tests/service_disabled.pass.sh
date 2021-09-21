#!/bin/bash
# packages = {{{ PACKAGENAME }}}

systemctl stop {{{ DAEMONNAME }}}
systemctl disable {{{ DAEMONNAME }}}
{{% if MASK_SERVICE %}}
systemctl mask {{{ DAEMONNAME }}}
{{% endif %}}
