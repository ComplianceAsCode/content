#!/bin/bash
# packages = {{{ PACKAGENAME }}}

systemctl stop {{{ DAEMONNAME }}}
systemctl disable {{{ DAEMONNAME }}}
