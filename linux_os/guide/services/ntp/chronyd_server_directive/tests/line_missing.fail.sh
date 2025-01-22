#!/bin/bash
# packages = chrony
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_almalinux
# remediation = none

echo "some line" > {{{ chrony_conf_path }}}
echo "another line" >> {{{ chrony_conf_path }}}
