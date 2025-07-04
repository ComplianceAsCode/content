#!/bin/bash
#
# remediation = bash

sed -i "/.*CREATE_HOME.*/d" {{{ login_defs_path }}}
