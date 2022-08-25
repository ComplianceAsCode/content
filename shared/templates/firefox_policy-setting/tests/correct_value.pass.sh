#!/bin/bash

firefox_cfg="policies.json"
firefox_dirs="/etc/firefox/policies"

# Iterate over the possible Firefox install directories
for firefox_dir in ${firefox_dirs}; do
    # write our test config in every location to ensure remediation fixes it.
    mkdir -p ${firefox_dir}
(
cat <<'zzzz1234EOF'
{{{ _CORRECT_CONFIG }}}
zzzz1234EOF
) > ${firefox_dir}/${firefox_cfg}
done
