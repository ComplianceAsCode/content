#!/bin/bash
# packages = chrony

{{% if product in ['ubuntu2204', 'ubuntu2404'] -%}}
echo "makestep 1 1" > {{{ chrony_conf_path }}}
{{% else -%}}
echo "makestep 1 -1" > {{{ chrony_conf_path }}}
{{% endif -%}}
