#!/bin/bash

firefox_cfg="distribution/policies.json"
firefox_dirs="/usr/lib/firefox /usr/lib64/firefox /usr/local/lib/firefox /usr/local/lib64/firefox"
{{{ find_python() }}}

# Iterate over the possible Firefox install directories
for firefox_dir in ${firefox_dirs}; do
    # write our bad config in every location to ensure remediation fixes it.
    mkdir -p ${firefox_dir}
    echo "{ \"policies\" :{ } }" > ${firefox_dir}/${firefox_cfg}

    echo """
import json
_file=open('${firefox_dir}/${firefox_cfg}', 'r')
_tree=json.load(_file)
_file.close()
{{% for policy_item in POLICIES %}}
{{% for p in policy_item.subpath %}}
if '{{{ p }}}' in _tree{{{ policy_item.path_python[loop.revindex] }}}:
   pass
else:
   _tree{{{ policy_item.path_python[loop.revindex0] }}} = dict()
{{% endfor %}}
# Remove the parameter
try:
    del _tree{{{ policy_item.path_python[0] }}}['{{{ policy_item.parameter }}}']
except KeyError:
    pass
{{% endfor %}}
_file=open('${firefox_dir}/${firefox_cfg}', 'w')
json.dump(_tree, _file, indent=4, sort_keys=True)
_file.close()
""" | ${__REMEDIATE_PYTHON}
done
