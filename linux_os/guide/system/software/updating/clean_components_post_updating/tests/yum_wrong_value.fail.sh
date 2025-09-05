#!/bin/bash
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel

file={{{ pkg_manager_config_file }}}

sed -i "/clean_requirements_on_remove/d" $file

echo "clean_requirements_on_remove = 0" >> $file
