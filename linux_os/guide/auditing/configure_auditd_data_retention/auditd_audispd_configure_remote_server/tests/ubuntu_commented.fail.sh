#!/bin/bash
# packages = audit,audispd-plugins
# platform = multi_platform_ubuntu
# variable = var_auditspd_remote_server=logcollector

{{{ set_config_file(path=audisp_conf_path + "/audisp-remote.conf",
                    parameter="Remote_server",
                    value="logcollector",
                    separator=" = ") }}}

{{{ set_config_file(path=audisp_conf_path + "/plugins.d/au-remote.conf",
                    parameter="Active",
                    value="yes",
                    separator=" = ") }}}

echo "#Remote_server = logcollector" > {{{ audisp_conf_path ~ "/audisp-remote.conf" }}}
echo "#Active = yes" > {{{ audisp_conf_path ~ "/plugins.d/au-remote.conf" }}}
