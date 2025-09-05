#!/bin/bash

firefox_cfg="policies.json"
firefox_dirs="/etc/firefox/policies"

# Iterate over the possible Firefox install directories
for firefox_dir in ${firefox_dirs}; do
    # write our test config in every location to ensure remediation fixes it.
    mkdir -p ${firefox_dir}
    (
cat <<'__EOF__'
{{{ _BAD_WRONG }}}
__EOF__
    ) > ${firefox_dir}/${firefox_cfg}
done
