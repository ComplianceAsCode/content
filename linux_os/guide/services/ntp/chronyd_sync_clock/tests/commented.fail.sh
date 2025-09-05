#!/bin/bash
# packages = chrony

{{% if product == 'ubuntu2204' -%}}
echo "# makestep 1 1" >> {{{ chrony_conf_path }}}
{{% else -%}}
echo "# makestep 1 -1" >> {{{ chrony_conf_path }}}
{{% endif -%}}
