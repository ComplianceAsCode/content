#!/bin/bash

firefox_cfg="policies.json"
firefox_dirs="/usr/lib/firefox/distribution /usr/lib64/firefox/distribution /usr/local/lib/firefox/distribution /usr/local/lib64/firefox/distribution"
_PYTHON=$(which python3)
if [ -x /usr/bin/python ]
    _PYTHON=/usr/bin/python
elif [ -x /usr/bin/python3 ]
    _PYTHON=/usr/bin/python3
elif [ -x /usr/bin/python2 ]
    _PYTHON=/usr/bin/python2
fi

# Iterate over the possible Firefox install directories
for firefox_dir in ${firefox_dirs}; do
    # write our bad config in every location to ensure remediation fixes it.
    mkdir -p ${firefox_dir}
    touch ${firefox_dir}/${firefox_cfg}
    echo """
import json
_file=open('${firefox_dir}/${firefox_cfg}', 'rb')
_tree=json.load(_file)
_file.close()
{{% for policy_item in POLICIES %}}
{{% for p in policy_item.subpath %}}
if '{{{ p }}}' in _tree{{{ policy_item.path_python[loop.revindex] }}}:
   pass
else:
   _tree{{{ policy_item.path_python[loop.revindex0] }}} = dict()
{{% endfor %}}
# Set the new value to the correct one
_tree{{{ policy_item.path_python[0] }}}['{{{ policy_item.parameter }}}'] = 'bad_value'
{{% endfor %}}
_file=open('${firefox_dir}/${firefox_cfg}', 'wb')
json.dump(_tree, _file, indent=4, sort_keys=True)
_file.close()
""" | ${_PYTHON}
done
