#!/bin/bash

firefox_cfg="policies.json"
firefox_dirs="/etc/firefox/policies"

# Iterate over the possible Firefox install directories
for firefox_dir in ${firefox_dirs}; do
    # write our bad config in every location to ensure remediation fixes it.
    mkdir -p ${firefox_dir}
(
cat <<'__EOF__'
{{{ _BAD_MISSING }}}
__EOF__
) > ${firefox_dir}/${firefox_cfg}
done
