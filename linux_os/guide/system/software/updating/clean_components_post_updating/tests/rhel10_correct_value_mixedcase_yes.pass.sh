#!/bin/bash
# platform = Red Hat Enterprise Linux 10

file={{{ pkg_manager_config_file }}}

sed -i "/clean_requirements_on_remove/d" "$file"
echo "clean_requirements_on_remove = yEs" >> "$file"
