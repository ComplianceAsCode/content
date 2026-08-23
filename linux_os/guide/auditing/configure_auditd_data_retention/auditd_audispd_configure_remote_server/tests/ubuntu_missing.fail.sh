#!/bin/bash
# packages = audit,audispd-plugins
# platform = multi_platform_ubuntu
# variable = var_auditspd_remote_server=logcollector

echo " Remote_server = logcollector" > {{{ audisp_conf_path ~ "/audisp-remote.conf" }}}
