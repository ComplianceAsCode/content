#!/bin/bash
# platform = Red Hat Enterprise Linux 9

file={{{ pkg_manager_config_file }}}

sed -i "/clean_requirements_on_remove/d" "$file"
echo "clean_requirements_on_remove = true" >> "$file"
